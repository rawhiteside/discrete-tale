require 'java'

import java.awt.Color
import org.foa.PixelBlock

# Parking methods here as I sort out mining. 
class MineUtils
  
  HUE_RANGES = {
    'yellow' => 1..60,
    'green' => 61..120,
    'cyan' => 121..180,
    'magenta' => 270..320,
    'blue' => 181..240,
    'red' => 301..360,
  }

  def self.slice_gems(pb, color_name)
    rect = pb.rect
    pb_gems = PixelBlock.construct_blank(rect, 0)
    0.upto(rect.width - 1) do |x|
      0.upto(rect.height - 1) do |y|
        pixel = pb.get_pixel(x, y)
        color = Color.new(pixel)
        hsb = Color.RGBtoHSB(color.red, color.green, color.blue, nil)
        hue = (hsb[0] * 360).to_i
        sat = (hsb[1] * 256).to_i
        if (pixel == 0xffffff) || (HUE_RANGES[color_name].cover?(hue))
          pb_gems.set_pixel(x, y, pixel)
          pb.set_pixel(x, y, 0)
        end
      end
    end
    
    pb_gems
  end

end
