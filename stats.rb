require 'java'

# XXX Figure out load-path stuff!
require File.expand_path('annotations.rb')



notes = Annotations.new

stats = {
  'Stone color' => Hash.new(0),
  'Gem color' => Hash.new(0),
  'Stone shape' => Hash.new(0),
  'Gem shape' => Hash.new(0),
}

notes.files.each do |file|
  notes[file].each_pair do |k, v|
    attr = stats[k]
    attr[v] += 1
  end
end

stats.each_key do |k|
  puts k
  stats[k].each_pair do |k,v|
    puts "  #{k}: #{v}"
  end
end

    
