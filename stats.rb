require 'java'

# XXX Figure out load-path stuff!
require File.expand_path('annotations.rb')

notes = Annotations.new

table = {
  'Stone color' => ['black', 'red', 'green', 'blue', 'cyan', 'magenta','yellow',].sort,
  'Gem color' => ['black', 'red', 'green', 'blue', 'cyan', 'magenta','yellow',].sort,
  'Stone shape' => ['pear', 'bowl', 'fingers', 'pillar', 'sphere', 'post', 'pancake'].sort,
  'Gem shape' => ['post', 'hex', 'fern', 'tree', 'cube', 'spikes', 'ashtray'].sort,
}

table.each_key do |aspect|
  puts aspect
  table[aspect].each do |attr|
    count = notes.images_matching {|attrs| attrs[aspect] == attr}.size
    puts "  #{attr}: #{count}"
  end
end
