require 'java'

require 'square_with_radius'

import java.awt.Color
import org.foa.PixelBlock

# Holds some image stuff for mining fooling around. 
class MinePixelBlock < PixelBlock
  
  HUE_RANGES = {
    'yellow' => 1..60,
    'green' => 61..120,
    'cyan' => 121..180,
    'magenta' => 270..320,
    'blue' => 181..240,
    'red' => 301..360,
  }
  
  public
  def image_points
    @image_points ||= points_matching {|pixel| pixel != 0}
  end

  # return array of points with colors matching the provided block.
  public
  def points_matching
    points = []
    0.upto(width-1) do |x|
      0.upto(height-1) do |y|
        points << Point.new(x, y) if yield get_pixel(x, y)
      end
    end

    points
  end

  public
  def draw_hull
    graphics = buffered_image.graphics
    graphics.color = Color::WHITE
    graphics.draw_polygon(hull)
  end

  def hull; @hull ||= ConvexHull.new(image_points); end

  def centroid; @centroid ||= compute_centroid; end

  private
  def compute_centroid
    xsum = ysum = 0
    image_points.each do |pt|
      ysum += pt.y
      xsum += pt.x
    end

    Point.new(xsum/npoints, ysum/npoints)
  end
  

  public
  def gem_color
    
  end

  public
  def slice_gems(color_name)
    r = rect
    pb_gems = PixelBlock.construct_blank(r, 0)
    0.upto(r.width - 1) do |x|
      0.upto(r.height - 1) do |y|
        pixel = get_pixel(x, y)
        color = Color.new(pixel)
        hsb = Color.RGBtoHSB(color.red, color.green, color.blue, nil)
        hue = (hsb[0] * 360).to_i
        sat = (hsb[1] * 256).to_i
        if (pixel == 0xffffff) || (HUE_RANGES[color_name].cover?(hue))
          pb_gems.set_pixel(x, y, pixel)
          set_pixel(x, y, 0)
        end
      end
    end
    
    pb_gems
  end

end
