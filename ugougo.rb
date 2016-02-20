require 'tmpdir'
require 'date'

class Ugougo
  ONE_TARN_STEP = 10 # 1ターンにどのくらい進むかどうか、戻るかどうか
  STEP = 30 # 100ステップランダムウォークするようにする(適当)
  OUTPUT_DIR = './out'

  def initialize(file_path)
    @file_path = file_path
  end

  def convert
    FileUtils.mkdir_p(OUTPUT_DIR)
    output_file_path = File.join OUTPUT_DIR, "#{DateTime.now.strftime('%Y%m%d%H%M%S')}.mp4"

    Dir.mktmpdir do |dir|
      `ffmpeg -i "#{@file_path}" -f image2 -vcodec mjpeg -qscale 1 -qmin 1 -qmax 1 #{dir}/img_%07d.jpg`

      images = Dir.glob("#{dir}/*.jpg")
      new_images = []
      current = 0

      STEP.times do |i|
        if next?
          new_images, current = next_step(images, new_images, current)
        else
          new_images, current = back_step(images, new_images, current)
        end
      end
      new_images.each_with_index do |image, index|
        image_name = sprintf('new_img_%07d.jpg', index+1)
        FileUtils.cp(image, "#{dir}/#{image_name}")
      end

      `ffmpeg -r 29.97 -i #{dir}/new_img_%07d.jpg -vcodec libx264 #{output_file_path}`
    end

    output_file_path
  end

  private

  # 次の画像に行くかどうか
  def next?
    (rand(10) + 1) > 4
  end

  def next_step(images, new_images, current)
    ONE_TARN_STEP.times do |i|
      image = images[current]
      break if image == nil
      new_images.push image
      current += 1
    end

    return new_images, current
  end

  def back_step(images, new_images, current)
    ONE_TARN_STEP.times do |i|
      image = images[current]
      break if image == nil
      new_images.push image
      current -= 1
    end

    return new_images, current
  end
end
