require 'java'
require 'yaml'

class Annotations
  ANNOTATION_FILE_NAME = File.join('orestone-pics', 'annotation.yaml')

  def initialize
    @annotations = load_annotations
  end

  def files_matching
    files = []
    @annotations.each_pair do |file, notes|
      files << file if yield notes
    end

    files
  end

  def files
    @annotations.keys
  end

  def [](file)
    @annotations[file]
  end

  def []=(file, notes)
    @annotations[file] = notes
    File.open(ANNOTATION_FILE_NAME, 'w'){|f| YAML.dump(@annotations, f)}
  end

  private
  def load_annotations
    if File.exist?(ANNOTATION_FILE_NAME)
      return YAML.load_file(ANNOTATION_FILE_NAME)
    else
      return {}
    end
  end
end
  
