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
import org.foa.Globifier

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
    @image_stone_hull = make_label
    @image_stone_backfill = make_label

    @image_gems = make_label
    @image_gems_clean = make_label

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
    stone_box.add @image_stone_hull
    stone_box.add @image_stone_backfill


    gem_box.add @image_gems
    gem_box.add @image_gems_clean

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
  
  def load_next_image(gem_color)
    image = @image_files.shift
    return false unless image
    @image_both.icon = ImageIcon.new(image)
    pb_both = PixelBlock.load_image(image)
    pb_stone = MinePixelBlock.new(pb_both)
    pb_gems = pb_stone.slice_gems(gem_color)
    pb_stone = cleanup(pb_stone)

    @image_stone.icon = ImageIcon.new(pb_stone.buffered_image)
    @image_gems.icon = ImageIcon.new(pb_gems.buffered_image)

    # Draw convex hull around image.
    pb_both_hull = MinePixelBlock.new(pb_both)
    pb_both_hull.draw_hull
    @image_both_hull.icon = ImageIcon.new(pb_both_hull.buffered_image)

    # Draw convex hull around image.
    mpb_stone_hull = MinePixelBlock.new(pb_stone)
    mpb_stone_hull.draw_hull
    @image_stone_hull.icon = ImageIcon.new(mpb_stone_hull.buffered_image)

    # Clean up gem view.
    mpb_gems_clean = cleanup(pb_gems)
    @image_gems_clean.icon = ImageIcon.new(mpb_gems_clean.buffered_image)

    mpb_stone_backfill = backfill_gems(pb_stone, pb_gems)
    @image_stone_backfill.icon = ImageIcon.new(mpb_stone_backfill.buffered_image)

    pack();

    true
  end

  def cleanup(pb)
    clean = MinePixelBlock.new(pb)
    globs = Globifier.globify(pb, 40000, 0)
    globs.each do |g|
      next if g.size > 50
      g.each {|p| clean.set_pixel(p, 0)}
    end

    clean
  end

  # Return a new image with gems inside the stone hull copied back in.
  def backfill_gems(stone, gems)
    backfill = MinePixelBlock.new(stone)
    points = stone.points_matching {|pixel| pixel != 0}
    poly = ConvexHull.new(points)
    0.upto(gems.width-1) do |x|
      0.upto(gems.height-1) do |y|
        pixel = gems.get_pixel(x, y)
        if pixel != 0
          if poly.contains(x, y)
            backfill.set_pixel(x, y, pixel) 
          end
        end
      end
    end

    backfill
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
