require 'java'
require 'yaml'

ANNOTATION_FILE_NAME = File.join('orestone-pics', 'annotation.yaml')
notes = YAML.load_file(ANNOTATION_FILE_NAME)

stats = {
  'Stone color' => Hash.new(0),
  'Gem color' => Hash.new(0),
  'Stone shape' => Hash.new(0),
  'Gem shape' => Hash.new(0),
}

notes.values.each do |stone|  # {gem-color => black, ...}
  stone.each_pair do |k, v|
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

    
