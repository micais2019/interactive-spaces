# rubocop:disable all

require 'concurrent'

start = Time.now
PATH = "/Users/adam/projects/MICA/interactive-spaces-code/image-generation/compositor_3d"

puts "GENERATING"

generator = Concurrent::FixedThreadPool.new(1)

10.times do |n|
  start_index = (n * 100) + 1
  puts "LAUNCH #{start_index}"

  generator << Proc.new do
    begin
      cmd = "processing-java --sketch=#{PATH} --run #{start_index}"
      system(cmd)
    rescue => ex
      puts "ERROR #{ex}"
    end
  end
end

generator.shutdown
generator.wait_for_termination

msg = "|  RUN TIME #{Time.now.to_f - start.to_f} SECONDS  |"

puts
puts "-" * msg.size
puts msg
puts "-" * msg.size
puts

# organize
output_dir = File.join(PATH, "output/*.png")
puts "OPTIMIZING #{output_dir}"

optimizer = Concurrent::FixedThreadPool.new(8)

Dir[output_dir].each do |image|
  optimizer << Proc.new do
    #  -zc levels
    #         Select the zlib compression levels used in IDAT compression.
    #         The  levels  argument  is  specified  as a rangeset (e.g. -zc6-9), and the default levels value depends on the optimization
    #         level set by the option -o.
    #         The effect of this option is defined by the zlib(3) library used by OptiPNG.
    #  -zm levels
    #         Select the zlib memory levels used in IDAT compression.
    #         The levels argument is specified as a rangeset (e.g. -zm8-9), and the default levels  value  depends  on  the  optimization
    #         level set by the option -o.
    #         The effect of this option is defined by the zlib(3) library used by OptiPNG.
    #  -zs strategies
    #         Select the zlib compression strategies used in IDAT compression.
    #         The strategies argument is specified as a rangeset (e.g. -zs0-3), and the default strategies value depends on the optimiza-
    #         tion level set by the option -o.
    #         The effect of this option is defined by the zlib(3) library used by OptiPNG.
    #  -zw size
    #         Select the zlib window size (32k,16k,8k,4k,2k,1k,512,256) used in IDAT compression.
    #         The size argument can be specified either in bytes (e.g. 16384) or kilobytes (e.g. 16k). The default size value is  set  to
    #         the lowest window size that yields an IDAT output as big as if yielded by the value 32768.
    #         The effect of this option is defined by the zlib(3) library used by OptiPNG.
    # zc = 9  zm = 8  zs = 0  f = 5
    cmd = "optipng -zc 9 -zm 8 -zs 0 -f 5 -o1 #{image} >> optipng.log"
    system(cmd)
  end
end

optimizer.shutdown
optimizer.wait_for_termination

fin = Time.now
puts "GENERATED IN #{fin.to_f - start.to_f} SECONDS"
