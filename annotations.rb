require 'java'
require 'yaml'

class Annotations < Hash
  ANNOTATION_FILE_NAME = File.join('orestone-pics', 'annotation.yaml')

  def initialize
    super()
    h = {}
    h = YAML.load_file(ANNOTATION_FILE_NAME) if File.exist?(ANNOTATION_FILE_NAME)
    @initializing = true
    h.each_pair {|k, v| self.store(k, v) }
    @initializing = false
  end

  def images_matching
    images = []
    each_pair do |image, notes|
      images << image if yield notes
    end

    images
  end

  def images
    keys
  end

  def []=(image, notes)
    super(image, notes)
    File.open(ANNOTATION_FILE_NAME, 'w'){|f| YAML.dump(self, f)} unless @initializing
  end
end
