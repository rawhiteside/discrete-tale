require 'java'
require 'yaml'

import javax.swing.JFrame
import javax.swing.JLabel
import javax.imageio.ImageIO
import javax.swing.ImageIcon
import javax.swing.JPanel
import javax.swing.JButton
import javax.swing.JComboBox
import javax.swing.BoxLayout
import javax.swing.Box
import javax.swing.WindowConstants


class MainFrame < JFrame
  include java.awt.event.ActionListener
  ANNOTATION_FILE_NAME = File.join('ore-stone-pics', 'annotation.yaml')
  
  def initialize
    super("Annotate ore stones")
    self.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

    @image_files = Dir.glob(File.join('orestone-pics', '*.png'))

    @annotations = load_annotations

    panel = JPanel.new
    self.get_content_pane.add(panel)
    box_layout = BoxLayout.new(panel, BoxLayout::Y_AXIS)
    panel.set_layout(box_layout)

    add_image(panel)
    load_next_image 

    @combos = []
    add_combo_boxes(panel)
    add_buttons(panel)
    
    self.pack();
    self.setVisible(true);
  end


  def load_next_image
    @image_file = @image_files.shift
    @filename_label.text = @image_file
    return nil unless @image_file
    image = ImageIO.read java.io.File.new(@image_file)
    0.upto(image.width - 1) do |x|
      0.upto(image.height - 1) do |y|
        if (image.getRGB(x, y) & 0xffffff) == 0
          image.setRGB(x, y, 0xFFFFFF)
        end
      end
    end
    icon = ImageIcon.new(image)
    @icon_label.icon = icon
    pack
    return true
  end

  
  def add_image(panel)
    @filename_label = JLabel.new(' ')
    add_centered panel, @filename_label
    
    icon = ImageIcon.new
    @icon_label = JLabel.new(icon)
    add_centered panel, @icon_label
  end

  def add_centered(panel, comp)
    box = Box.create_horizontal_box
    box.add Box.create_horizontal_glue
    box.add comp
    box.add Box.create_horizontal_glue
    panel.add(box)
  end

  def load_annotations
    if File.exist?(ANNOTATION_FILE_NAME)
      return YAML.load_file(ANNOTATION_FILE_NAME)
    else
      return {}
    end
  end

  

  def add_combo_boxes(panel)
    colors = ['red', 'blue', 'green', 'cyan', 'magenta', 'yellow', 'black'].sort
    panel.add(make_combo("Gem color", colors))
    panel.add(make_combo("Stone color", colors))

    gem_shapes = ['post', 'cube', 'spikes', 'fern', 'hex', 'tree', 'ashtray'].sort
    panel.add(make_combo("Gem shape", gem_shapes))

    stone_shapes = ['pear', 'bowl', 'fingers', 'post', 'pillar', 'sphere', 'pancake'].sort
    panel.add(make_combo("Stone shape", stone_shapes))
  end

  def add_buttons(panel)
    bnext = JButton.new("Next")
    bnext.add_action_listener self

    bskip = JButton.new("Skip")
    bskip.add_action_listener self

    bexit = JButton.new("Exit")
    bexit.add_action_listener self

    box = Box.create_horizontal_box
    box.add bnext
    panel.add Box.create_horizontal_glue
    box.add bskip
    panel.add Box.create_horizontal_glue
    box.add bexit
    panel.add box
  end

  def make_combo(label, choices)
    box = Box.create_horizontal_box
    combo = JComboBox.new
    combo.action_command = label
    choices.each{ |c| combo.add_item(c) }

    label = JLabel.new(label)
    box.add(label)
    box.add Box.create_horizontal_glue
    box.add(combo)

    @combos << combo

    box
  end

  def update_annotation
    @combos.each do |combo|
    end
  end
  


  def actionPerformed(e)
    case e.action_command
    when 'Exit'
      dispose
    when 'Next'
      update_annotation
      load_next_image
    when 'Skip'
      puts 'skip'
      load_next_image
    end
  end

end
if __FILE__ == $0
  MainFrame.new
end

