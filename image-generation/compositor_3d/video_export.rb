# rubocop:disable all
# look in final/ export PDF pages as cropped, resized, sRGB JPG images


require 'fileutils'

curdir = FileUtils.pwd

finals = File.join(curdir, 'final', '*.pdf')

cs_in  = File.join(curdir, 'data', 'psocoated-v3.icc')
cs_out = File.join(curdir, 'data', 'sRGB2014.icc')

frames_path = File.join(curdir, 'frames', '%05i', '%%03d.jpg')

Dir[finals].each do |pdf|
  start_idx = /(\d+)-\d+-cmyk/.match(File.basename(pdf))[1]
  start_idx = start_idx.to_i

  current_frames_path = frames_path % [start_idx]
  puts "PDF #{pdf} @ #{start_idx} -> #{current_frames_path}"

  FileUtils.mkdir_p(File.dirname(current_frames_path))
  
  # input was originally 4276x3000 @ 72dpi to 14.25"x10" @ 300dpi
  convert_command = %(magick convert -density 300 "#{pdf}" -resize 1026x720 -profile "#{cs_in}" -profile "#{cs_out}"  -gravity Center -crop 980x674+0+0 "#{current_frames_path}")
  puts "> #{convert_command}"

  start = Time.now
  begin
    system convert_command
  rescue => ex
    puts ">> ERROR: #{convert_command}"
  end

  puts "  DONE IN #{(Time.now - start)} SECONDS"
end
