REPLACEMENTS = [
  [/(\d+(\.\d+)*)%/, 'Percent.new(\1)'],
  [/\$(\d+(\.\d+)*)/, 'Dollar.new(\1)'],
  [/(?<=[^\w])(mo)(?=[^\w])/, 'TimePeriod.new(MONTH)']
]
THIS_DIR = File.dirname(__FILE__)

def parse(filename, destination)
  file_out = File.join(THIS_DIR, destination)
  file_in = File.join(THIS_DIR, filename)

  File.open(file_out, 'w') do |f_out|
    File.open(file_in) do |f|
      while line = f.gets
        REPLACEMENTS.each do |r|
          line.gsub!(*r)
        end
        f_out.puts line
      end
    end
  end
end

if filename = ARGV[0]
  parse(filename, ARGV[1])
end

