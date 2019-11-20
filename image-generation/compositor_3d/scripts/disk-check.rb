
pages = 68000
per_pdf = 100
documents = pages / per_pdf
source = File.join('//Volumes', 'Elements', 'final')

documents.times do |doc_n|
  filename = "#{(doc_n * 100) + 1}-#{(doc_n + 1) * 100}-cmyk.pdf"
  a_file = File.join(source, filename)

  if File.exist?(a_file)
    puts format('%-22s ✓', a_file)
  else
    puts "ERROR: could not find #{a_file}"
  end
end

