# rubocop:disable all
# look in final/ export PDF pages as cropped, resized, sRGB JPG images

pdf = ARGV[0]
index = ARGV[1]

require 'fileutils'

curdir = FileUtils.pwd

extract_path = File.join(curdir, 'extract')
cs_in  = File.join(curdir, 'data', 'psocoated-v3.icc')

FileUtils.mkdir_p(extract_path)



puts "checking #{pdf}[#{index}]"

if File.exist?(pdf)
  start_idx = /(\d+)-\d+-cmyk/.match(File.basename(pdf))[1]
  start_idx = start_idx.to_i
  outfile = File.join(extract_path, "#{start_idx + index.to_i}.tif")

  puts "PDF #{pdf} @ #{index} -> #{outfile}"

  # input was 4276x3000 @ 72dpi to 14.25"x10" @ 300dpi
  extract_command = %(magick convert -density 300 "#{pdf}[#{index}]" -profile "#{cs_in}" "#{outfile}")
  puts "> #{extract_command}"

  start = Time.now
  begin
    system extract_command
  rescue => ex
    puts ">> ERROR: #{extract_command}"
  end

  puts "  DONE IN #{(Time.now - start)} SECONDS"
end
