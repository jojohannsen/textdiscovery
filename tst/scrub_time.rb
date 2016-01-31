lines = File.open(ARGV[0], "r").readlines
lines.each do |line|
  line.chomp!
  data = line.split("created_at")
  if (data.length > 1) then
    (1..(data.length-1)).each do |offset|
      # replace the timing information with "*"
      data[offset] = '":"*"' + data[offset][29..-1]
    end
    line = data.join('created_at')
    data = line.split("updated_at")
    (1..(data.length-1)).each do |offset|
      data[offset] = '":"*"' + data[offset][29..-1]
    end
    print data.join('updated_at')
    print '\n'
  else 
    print "#{line}\n"
  end
end
