require 'java'

# XXX Figure out load-path stuff!
require 'abstract_mine'
require 'annotations'

import java.awt.Dimension
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

import org.foa.PixelBlock

class MainFrame < JFrame
  include java.awt.event.ActionListener
  
  HUE_RANGES = {
    'green' => 61..120,
    'blue' => 241..300,
  }

  def initialize
    super("Annotate ore stones")
    self.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
    
    target = 'blue'
    @image_files = Annotations.new.images_matching {|attrs|
      attrs['Gem color'] == target && attrs['Stone color'] != target
    }
    if @image_files.size == 0
      puts "No matching files"
      return
    end

    panel = JPanel.new
    box_layout = BoxLayout.new(panel, BoxLayout::Y_AXIS)
    panel.set_layout(box_layout)
    self.get_content_pane.add(panel)

    add_images panel
    load_next_image

    add_buttons panel

    pack();
    setVisible(true);
  end

  def add_images(panel)
    @icon_label_orig = JLabel.new
    @icon_label_stone = JLabel.new
    @icon_label_gems = JLabel.new
    box = Box.create_horizontal_box
    box.add Box.create_rigid_area(Dimension.new(5, 0))
    box.add @icon_label_orig
    box.add Box.create_rigid_area(Dimension.new(5, 0))
    box.add @icon_label_stone
    box.add Box.create_rigid_area(Dimension.new(5, 0))
    box.add @icon_label_gems
    box.add Box.create_rigid_area(Dimension.new(5, 0))
    panel.add box
  end

  def add_buttons(panel)
    bnext = JButton.new("Next")
    bnext.add_action_listener self
    bexit = JButton.new("Exit")
    bexit.add_action_listener self

    box = Box.create_horizontal_box
    box.add bnext
    box.add bexit
    panel.add box
  end
  

  def load_next_image
    image = @image_files.shift
    return false unless image
    @icon_label_orig.icon = ImageIcon.new(image)
    pb_orig = PixelBlock.load_image(image)
    rect = pb_orig.rect
    pb_stone = PixelBlock.construct_blank(rect, 0)
    pb_gems = PixelBlock.construct_blank(rect, 0)
    0.upto(rect.width - 1) do |x|
      0.upto(rect.height - 1) do |y|
        pixel = pb_orig.get_pixel(x, y)
        color = Color.new(pixel)
        hsb = Color.RGBtoHSB(color.red, color.green, color.blue, nil)
        hue = (hsb[0] * 360).to_i
        if (pixel == 0xffffff) || (hue > 60 && hue <= 120)
          pb_gems.set_pixel(x, y, pixel)
          pb_stone.set_pixel(x, y, 0)
        else
          pb_stone.set_pixel(x, y, pixel)
        end
      end
    end
    

    @icon_label_stone.icon = ImageIcon.new(pb_stone.buffered_image)
    @icon_label_gems.icon = ImageIcon.new(pb_gems.buffered_image)
    pack();

    true
  end

  def actionPerformed(e)
    case e.action_command
    when 'Exit'
      dispose
    when 'Next'
      dispose unless load_next_image
    end
  end
end
if __FILE__ == $0
  MainFrame.new
end
