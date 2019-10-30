# rubocop:disable all

require 'concurrent'
require 'fileutils'
require 'socket'

def log(*msg_args)
  puts "[#{Time.now}] #{msg_args.map(&:to_s).join(' ')}"
end

start = Time.now
# change

REMOTE = /^ip-1/ =~ Socket.gethostname

if REMOTE
  # AWS server
  PATH = File.expand_path "~/interactive-spaces/image-generation/compositor_3d"
else
  # my machine
  PATH = File.expand_path "~/projects/MICA/interactive-spaces-code/image-generation/compositor_3d"
end

GENERATE_IMAGES = true
CONVERT_IMAGES = false
BUNDLE_PDF = false
UPLOAD_PDF = true && REMOTE

log("GENERATING") if GENERATE_IMAGES
log("CONVERTING") if CONVERT_IMAGES
log("BUNDLING") if BUNDLE_PDF
log("UPLOADING") if UPLOAD_PDF

QUANTITY_PER_GENERATION = 10 # number of images the processing sketch will generate on a single run
GENERATIONS = 680

STARTING_INDEX = 1

EXPECTED_QUANTITY = 6800 # total number of images to be generated

BUNDLE_GROUPS_OF = 100

# passing images from converter to bundler
bundle_queue = Concurrent::Array.new

generator = Concurrent::FixedThreadPool.new(1)

if GENERATE_IMAGES
  GENERATIONS.times do |n|
    start_index = STARTING_INDEX + (QUANTITY_PER_GENERATION * n) * 10

    generator << Proc.new do
      # log "LAUNCH #{start_index}"

      begin
        # the processing sketch includes logic for generating a sequence of images
        if REMOTE
          cmd = "xvfb-run ~/processing-3.5.3/processing-java --sketch=#{PATH} --run #{start_index}"
        else
          cmd = "processing-java --sketch=#{PATH} --run #{start_index}"
        end
        log "RUN #{cmd}"
        # system(cmd)
      rescue => ex
        log "ERROR #{ex}"
      end
    end
  end
end

conversion_worker = nil
if CONVERT_IMAGES
  converter = Concurrent::FixedThreadPool.new(8)
  counter = Concurrent::AtomicFixnum.new(0)

  conversion_worker = Thread.new do
    # organize
    output_path = File.join(PATH, "output/*.tiff")

    loop do
      puts "[#{Time.now}] CHECKING FOR OUTPUT #{output_path}"

      to_convert = 0
      Dir[output_path].each do |image|
        to_convert += 1
        converter << Proc.new do
          fn = File.basename(image)
          name, ftype = fn.split('.')
          time, idx, _, _ = name.split('_')

          # overlay
          crop_name  = File.join PATH, "crop",  "%i_%i.%s" % [time, idx, ftype]
          if !File.exists?(crop_name)
            log "add crops to #{image}"

            # geometry values here come from crop_marks_generator
            #  actual crops.png file:
            #    Oct 30 10:43 data/crops.png PNG 4276x3000 4276x3000+0+0 8-bit sRGB 56392B 0.000u 0:00.001
            #  output from crops sketch:
            #    border 77.0
            overlay_command = "convert -size 4276x3000 xc:white \\( #{image} \\) -geometry +77+77 -composite \\( data/crops.png \\) -geometry +0+0 -composite #{crop_name}"
            system(overlay_command)

            log "removing #{image}"
            FileUtils.rm(image)
          end

          # colorspace
          print_name = File.join PATH, "print", "%i_%i.%s" % [time, idx, ftype]
          if !File.exists?(print_name)
            log "convert colorspace of #{crop_name}"
            convert_command = "convert #{crop_name} -profile data/sRGB2014.icc -profile data/psocoated-v3.icc #{print_name}"
            system(convert_command)

            log "removing #{crop_name}"
            if !REMOTE
              identify_command = "identify #{print_name}"
              puts system(identify_command)
            end

            log "removing #{crop_name}"
            FileUtils.rm(crop_name)
          end

          # append print output to bundle queue
          log "append #{print_name} to bundle queue"
          bundle_queue << print_name
          bundle_queue.sort

          counter.increment
        end
      end

      if to_convert > 0
        log "dispatching conversion of #{to_convert} images"
      else
        log "no images to convert"

        if counter.value === EXPECTED_QUANTITY
          log "all images processed"
          bundle_queue << :end
          break
        end
      end

      sleep 10
    end
  end
end

bundler_worker = nil
if BUNDLE_PDF
  bundler = Concurrent::FixedThreadPool.new(4)
  if UPLOAD_PDF
    uploader = Concurrent::FixedThreadPool.new(8)
  end

  bundler_worker = Thread.new do
    loop do
      if bundle_queue.size >= BUNDLE_GROUPS_OF || bundle_queue.last == :end
        if bundle_queue.last == :end
          slice = bundle_queue[0..-2]
        else
          slice = bundle_queue.shift(BUNDLE_GROUPS_OF)
        end

        bundler << Proc.new do
          log "BUNDLING #{slice.size} FILES"
          sorted = slice.sort

          first_file = File.basename(sorted.first)
          first_file = first_file.split('.')[0]
          last_file  = File.basename(sorted.last)
          last_file  = last_file.split('.')[0]

          start_idx  = first_file.split('_')[1]
          end_idx    = last_file.split('_')[1]

          log "  #{start_idx} - #{end_idx}"

          pdf_name   = "#{start_idx}-#{end_idx}-cmyk.pdf"

          slice_file_paths = slice.join(' ')
          final_path = File.join(PATH, "final", pdf_name)

          bundle_command = "convert #{slice_file_paths} #{final_path}"
          log "bundle .tiff files into PDF: #{bundle_command}"
          system(bundle_command)

          if File.exists?(final_path)
            removal_command = "rm #{slice_file_paths}"
            log "remove files #{removal_command}"
            system(removal_command)
          end

          if UPLOAD_PDF
            uploader << Proc.new do
              upload_command = "aws s3 cp #{final_path} s3://micavibe/print-final-pdfs/ --acl public-read"
              log "uploading #{upload_command}"
              system(upload_command)


              pdf_removal_command = "rm #{final_path}"
              log "remove files #{pdf_removal_command}"
              system(pdf_removal_command)
            end
          end
        end
      end

      if bundle_queue.last == :end
        log "bundler loop breaking"
        break
      end

      log "bundler waiting for files..."
      sleep 15
    end
  end
end

if GENERATE_IMAGES
  generator.shutdown
  generator.wait_for_termination
end

if conversion_worker
  conversion_worker.join
end

if bundler_worker
  bundler_worker.join
end

if CONVERT_IMAGES
  converter.shutdown
  converter.wait_for_termination
end

if BUNDLE_PDF
  bundler.shutdown
  bundler.wait_for_termination

  if UPLOAD_PDF
    uploader.shutdown
    uploader.wait_for_termination
  end
end

fin = Time.now
puts "GENERATED IN #{fin.to_f - start.to_f} SECONDS"
