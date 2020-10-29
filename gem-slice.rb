require 'java'

require 'abstract_mine'
require 'mine-utils'
require 'annotations'
require 'convexhull'

import java.awt.Dimension
import java.awt.Polygon
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

  def initialize
    super("Annotate ore stones")
    @gem_color = 'magenta'

    self.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
    
    @image_files = Annotations.new.images_matching {|attrs|
      attrs['Gem color'] == @gem_color && attrs['Stone color'] != @gem_color
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
    load_next_image @gem_color

    add_buttons panel

    pack();
    setVisible(true);
  end

  def make_label
    l = JLabel.new
    l.set_border(EmptyBorder.new(10, 10, 10, 10))
    l
  end

  def add_images(panel)
    @image_both = make_label
    @image_both_hull = make_label
    @image_stone = make_label
    @image_gems = make_label

    hbox = Box.create_horizontal_box
    both_box = Box.create_vertical_box
    hbox.add(both_box)
    stone_box = Box.create_vertical_box
    hbox.add(stone_box)
    gem_box = Box.create_vertical_box
    hbox.add(gem_box)
    
    both_box.add @image_both
    both_box.add @image_both_hull
    stone_box.add @image_stone
    gem_box.add @image_gems
    panel.add hbox
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
  
  def points_matching(pb)
    points = []
    0.upto(pb.width-1) do |x|
      0.upto(pb.height-1) do |y|
        points << Point.new(x, y) if yield pb.get_pixel(x, y)
      end
    end

    points
  end

  def load_next_image(gem_color)
    image = @image_files.shift
    return false unless image
    @image_both.icon = ImageIcon.new(image)
    pb_both = PixelBlock.load_image(image)
    pb_stone = PixelBlock.new(pb_both)
    pb_gems = MineUtils.slice_gems(pb_stone, gem_color)

    @image_stone.icon = ImageIcon.new(pb_stone.buffered_image)
    @image_gems.icon = ImageIcon.new(pb_gems.buffered_image)

    # Draw convex hull around image.
    points = points_matching(pb_both) {|pixel| pixel != 0}
    hull = ConvexHull.calculate(points)
    x, y = [], []
    hull.each do |pt|
      x << pt.x
      y << pt.y
    end
    pb_both_hull = PixelBlock.new(pb_both)
    graphics = pb_both_hull.buffered_image.graphics
    graphics.color = Color::WHITE
    graphics.draw_polygon(x.to_java(:int), y.to_java(:int), x.size)
    @image_both_hull.icon = ImageIcon.new(pb_both_hull.buffered_image)

    pack();

    true
  end

  def actionPerformed(e)
    case e.action_command
    when 'Exit'
      dispose
    when 'Next'
      dispose unless load_next_image @gem_color
    end
  end
end
if __FILE__ == $0
  MainFrame.new
end
