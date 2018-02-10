require 'rmagick'
include Magick

class Skin2d
  attr_accessor :image
  WIDTH_IMAGE = 64
  HEIGHT_IMAGE = 32
  FORMAT = "PNG"

  def initialize(image = nil)
    raise 'image cannot be loaded' if image.nil?
    raise 'image not exists' unless File.exist? image
    @image = ImageList.new(image).first
    raise 'could not open PNG file' if @image.nil?
    raise 'invalid image' unless valid?
  end

  def combined_image(scale = 1)
    newWidth = 37 * scale
    newHeight = 32 * scale
    #imagefilledrectangle
    #TODO: white to rgb
    @new_image = ImageList.new.new_image(37, 32) { self.background_color = "white"}

    #x,y,w,h
    @new_image = image_copy(@new_image, @image, 4, 0, 8, 8, 8, 8)
    @new_image = image_copy_alpha(@new_image, @image, 4, 0, 40, 8, 8, 8, image_color_at(@image, 63, 0))
    @new_image = image_copy(@new_image, @image, 4, 8, 20, 20, 8, 12)
    @new_image = image_copy(@new_image, @image, 8, 20, 4, 20, 4, 12)
    @new_image = image_copy(@new_image, @image, 4, 20, 4, 20, 4, 12)
    @new_image = image_copy(@new_image, @image, 12, 8, 44, 20, 4, 12)
    @new_image = image_copy(@new_image, @image, 0, 8, 44, 20, 4, 12)

    @new_image = image_copy(@new_image, @image, 25, 0, 24, 8, 8, 8)
    @new_image = image_copy_alpha(@new_image, @image, 25, 0, 56, 8, 8, 8, image_color_at(@image, 63, 0))
    @new_image = image_copy(@new_image, @image, 25, 8, 32, 20, 8, 12)
    @new_image = image_copy(@new_image, @image, 29, 20, 12, 20, 4, 12)
    @new_image = image_copy(@new_image, @image, 25, 20, 12, 20, 4, 12)
    @new_image = image_copy(@new_image, @image, 33, 8, 52, 20, 4, 12)
    @new_image = image_copy(@new_image, @image, 21, 8, 52, 20, 4, 12)

    unless scale == 1
      @new_image.scale!(scale)
    end

    save_image(@new_image)
  end

  private

  def save_image(image = nil, name = 'result.png')
    return if image.nil?
    image.write(name)
  end

  #@new_image.to_blob { self.format = "png" }

  def image_copy(dst_im, src_im, dst_x, dst_y, src_x, src_y, src_w, src_h)
    sub_img = src_im.dispatch(src_x, src_y, src_w, src_h, "RGB") #get a part of image
    pixels = Image.constitute(src_w, src_h, "RGB", sub_img) #save subpart to image
    dst_im = dst_im.composite(pixels, dst_x, dst_y, AddCompositeOp) #mix images
    dst_im
  end

  def image_copy_alpha(dst, src, dst_x, dst_y, src_x, src_y, w, h, bg)
    (0...w).each do |i|
      (0...h).each do |j|
        color = image_color_at(src, src_x + i, src_y + j)
        rgb = image_color_rgb_binary(color)
        bin_bg = image_color_rgb_binary(bg)
        if ((rgb & 0xffffff) == (bin_bg & 0xffffff))
          alpha = 127
        else
          alpha = get_alpha(color)
        end
        dst = image_copy(dst, src, (dst_x + i), (dst_y + j), (src_x + i), (src_y + j), 1, 1)
      end
    end
    dst
  end

  def image_color_at(img, x, y)
    pix = img.get_pixels(x, y, 1, 1).first
    Pixel.new(pix.red, pix.green, pix.blue)
  end

  def image_color_hex_str(pixel)
    pixel.to_color(AllCompliance, true, 8, true)
  end

  def image_color_rgb_binary(pixel)
    res = image_color_hex_str(pixel)
    res[1..res.length].hex
  end

  def get_alpha(pixel)
    pixel.to_hsla[3]
  end

  def width
    raise 'image not loaded' if @image.nil?
    @image.columns
  end

  def height
    raise 'image not loaded' if @image.nil?
    @image.rows
  end

  def image_format
    raise 'image not loaded' if @image.nil?
    @image.format
  end

  def valid?
    return true if width == WIDTH_IMAGE &&
                   height == HEIGHT_IMAGE &&
                   image_format == FORMAT
  end
end
