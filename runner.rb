require_relative 'skin2d.rb'

puts 'Enter filename (default is sd.png):'
filename = gets.chomp
filename = 'sd.png' if filename.length.zero?
puts 'Enter scale (default is 5):'
scale = gets.chomp.to_i
scale = 5 if scale.zero?

Skin2d.new(filename).combined_image(scale)
puts 'Image saved as result.png'
