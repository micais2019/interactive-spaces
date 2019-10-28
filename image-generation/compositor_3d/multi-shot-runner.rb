# rubocop:disable all

require 'concurrent'

start = Time.now
PATH = "/Users/adam/projects/MICA/interactive-spaces-code/image-generation/compositor_3d"

GENERATE_IMAGES = false
CONVERT_IMAGES = true
BUNDLE_PDF = true

BUNDLE_GROUPS_OF = 10

generator = Concurrent::FixedThreadPool.new(1)

if GENERATE_IMAGES
  puts "GENERATING"
  # 10.times do |n|
    start_index = 13001
    puts "LAUNCH #{start_index}"

    generator << Proc.new do
      begin
        cmd = "processing-java --sketch=#{PATH} --run #{start_index}"
        system(cmd)
      rescue => ex
        puts "ERROR #{ex}"
      end
    end
  # end

  generator.shutdown
  generator.wait_for_termination

  msg = "|  RUN TIME #{Time.now.to_f - start.to_f} SECONDS  |"

  puts
  puts "-" * msg.size
  puts msg
  puts "-" * msg.size
  puts
end

if CONVERT_IMAGES
  # organize
  output_path = File.join(PATH, "output/*.png")
  puts "APPLYING CROPS #{output_path}"

  converter = Concurrent::FixedThreadPool.new(8)

  Dir[output_path].each do |image|
    converter << Proc.new do
      # # optimize
      # cmd = "optipng -zc 9 -zm 8 -zs 0 -f 5 -o1 #{image} >> optipng.log"
      # system(cmd)

      fn = File.basename(image)
      name, ftype = fn.split('.')
      time, idx, _, _ = name.split('_')
      crop_name = File.join PATH, "crop", "%i_%i_4240_3000.%s" % [time, idx, ftype]
      print_name = File.join PATH, "print", "%i_%i_4240_3000.tiff" % [time, idx]

      # overlay
      if !File.exists?(crop_name)
        puts "add crops to #{image}"
        overlay_command = "convert -size 4240x3000 xc:white \\( #{image} \\) -geometry +77+77 -composite \\( data/crops.png \\) -geometry +0+0 -composite #{crop_name}"
        system(overlay_command)
      end

      # colorspace
      if !File.exists?(print_name)
        puts "convert colorspace of #{crop_name}"
        convert_command = "convert #{crop_name} -profile data/sRGB2014.icc -profile data/psocoated-v3.icc #{print_name}"
        system(convert_command)
      end
    end
  end

  converter.shutdown
  converter.wait_for_termination
end

if BUNDLE_PDF
  print_path = File.join(PATH, "print/*.tiff")

  bundler = Concurrent::FixedThreadPool.new(2)

  Dir[print_path].each_slice(BUNDLE_GROUPS_OF) do |slice|
    bundler << Proc.new do
      puts "BUNDLING #{slice.size} FILES"
      sorted = slice.sort

      first_file = File.basename(sorted.first)
      last_file  = File.basename(sorted.last)

      start_idx  = first_file.split('_')[1]
      end_idx    = last_file.split('_')[1]

      puts "  #{start_idx} - #{end_idx}"

      pdf_name   = "#{start_idx}-#{end_idx}-cmyk.pdf"
      slice_glob = "print/*_{#{start_idx}..#{end_idx}}_*.tiff"

      puts "slice_glob #{slice_glob}"
      bundle_command = "convert #{slice_glob} final/#{pdf_name}"
      puts "bundle .tiff files into PDF: #{bundle_command}"
      system(bundle_command)
    end
  end

  bundler.shutdown
  bundler.wait_for_termination
end

fin = Time.now
puts "GENERATED IN #{fin.to_f - start.to_f} SECONDS"
