# rubocop:disable all

require 'concurrent'
require 'fileutils'
require 'socket'
require 'logger'

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

def log(*msg_args)
  message = msg_args.map(&:to_s).join(' ')
  puts "[#{Time.now}] #{message}"
  $logger.debug(message)
end

$logger = Logger.new(File.join(PATH, 'output.log'), 10, 1024000)

GENERATE_IMAGES = true
CONVERT_IMAGES = true
BUNDLE_PDF = true
UPLOAD_PDF = true # && REMOTE

QUANTITY_PER_GENERATION = 10 # number of images the processing sketch will generate on a single run
GENERATION_SKIP_FACTOR = 100
GENERATIONS = 68
STARTING_INDEX = 1
EXPECTED_QUANTITY = QUANTITY_PER_GENERATION * GENERATIONS # total number of images to be generated
BUNDLE_GROUPS_OF = 50

# passing images from converter to bundler
bundle_queue = Concurrent::Array.new
bundle_map = Concurrent::Hash.new

TOTAL_BUNDLE_QUANTITY = ((GENERATIONS * QUANTITY_PER_GENERATION) / BUNDLE_GROUPS_OF.to_f).ceil
TOTAL_BUNDLE_QUANTITY.times do |n|
  bundle_map[n] = []
end

current_bundle_remaining = BUNDLE_GROUPS_OF
current_bundle = 0
GENERATIONS.times do |n|
  start_index = STARTING_INDEX + (QUANTITY_PER_GENERATION * n) * GENERATION_SKIP_FACTOR
  next_index = start_index
  QUANTITY_PER_GENERATION.times do |m|
    bundle_map[current_bundle] << next_index

    next_index += 1
    current_bundle_remaining -= 1

    if current_bundle_remaining == 0
      current_bundle += 1
      current_bundle_remaining = BUNDLE_GROUPS_OF
    end
  end
end

# bundle_map now contains a listing of the images that should be included in each bundle (by counter)
log("GENERATING") if GENERATE_IMAGES
log("CONVERTING") if CONVERT_IMAGES
log("BUNDLING") if BUNDLE_PDF
log("UPLOADING") if UPLOAD_PDF

generator = Concurrent::FixedThreadPool.new(1)

log "preparing #{TOTAL_BUNDLE_QUANTITY} bundled PDFs of #{BUNDLE_GROUPS_OF} images each"

if GENERATE_IMAGES
  GENERATIONS.times do |n|
    start_index = STARTING_INDEX + (QUANTITY_PER_GENERATION * n) * GENERATION_SKIP_FACTOR

    generator << Proc.new do
      # log "LAUNCH #{start_index}"
      begin
        # the processing sketch includes logic for generating a sequence of images
        if REMOTE
          cmd = "xvfb-run -a -e /dev/stdout ~/processing-3.5.3/processing-java --sketch=#{PATH} --run #{start_index}"
        else
          cmd = "processing-java --sketch=#{PATH} --run #{start_index}"
        end
        log "RUN #{cmd}"
        system(cmd)

        sleep 3
      rescue => ex
        $logger.error ex.message
        $logger.error ex.stacktrace[0..8].join("\n")
        log "ERROR #{ex}"
      end
    end
  end
end

conversion_worker = nil
if CONVERT_IMAGES
  converter = Concurrent::FixedThreadPool.new(6)
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
            success = system(overlay_command)

            # only delete last stage when next stage is available
            if success && File.exists?(crop_name)
              log "removing #{image}"
              FileUtils.rm(image)
            else
              log "ERROR ADDING CROPS TO #{image}"
              $logger.error "failed to add crops to #{image}"
            end
          end

          # colorspace
          print_name = File.join PATH, "print", "%i_%i.%s" % [time, idx, ftype]
          if !File.exists?(print_name)
            log "convert colorspace of #{crop_name}"
            convert_command = "convert #{crop_name} -profile data/sRGB2014.icc -profile data/psocoated-v3.icc #{print_name}"
            success = system(convert_command)

            if success && File.exists?(print_name)
              log "removing #{crop_name}"
              FileUtils.rm(crop_name)
            else
              log "ERROR CHANGING COLOR PROFILE OF #{crop_name}"
              $logger.error  "error changing color profile of #{crop_name}"
            end
          end

          # append print-ready filename to bundle queue
          if File.exists?(print_name)
            log "append #{print_name} to bundle queue"
            bundle_queue << print_name
          end

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
else
  # add all files in print/ to bundle_queue
  print_path = File.join(PATH, "print/*.tiff")
  Dir[print_path].each do |fn|
    bundle_queue << fn
  end
end

bundler_worker = nil
if BUNDLE_PDF
  bundler = Concurrent::FixedThreadPool.new(2)
  if UPLOAD_PDF
    uploader = Concurrent::FixedThreadPool.new(4)
  end

  bundler_worker = Thread.new do
    loop do
      if bundle_queue.size >= BUNDLE_GROUPS_OF || bundle_queue.last == :end
        slice = nil

        TOTAL_BUNDLE_QUANTITY.times do |bundle_index|
          if bmap = bundle_map[bundle_index]

            # search the whole list of prepared files
            okaygo = true
            bmap.each do |bidx|
              idx_in_queue = bundle_queue.find_index {|fname| /\d+_#{bidx}.tiff/ =~ fname}
              if idx_in_queue.nil?
                okaygo = false
              end
            end

            if okaygo
              log "  #{bundle_index} IS READY TO GO"
              slice = []

              bmap.each do |bidx|
                idx_in_queue = bundle_queue.find_index {|fname| /\d+_#{bidx}.tiff/ =~ fname}
                unless idx_in_queue.nil?
                  slice << bundle_queue.delete_at(idx_in_queue)
                end
              end

              break
            end
          else
            log "  BUNDLE #{bundle_index} HAS ALREADY BEEN CREATED"
          end
        end

        if slice
          ## if a complete bundle worth of files in print/*.tiff exists...
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
                if REMOTE
                  upload_command = "aws s3 cp #{final_path} s3://micavibe/print-final-pdfs/ --acl public-read"
                else
                  upload_command = "aws --profile micavibe s3 cp #{final_path} s3://micavibe/print-final-pdfs/ --acl public-read"
                end

                log "uploading #{upload_command}"
                system(upload_command)

                pdf_removal_command = "rm #{final_path}"
                log "remove files #{pdf_removal_command}"
                system(pdf_removal_command)
              end
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
