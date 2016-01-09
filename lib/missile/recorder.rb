require 'rubygems'
require 'rmagick'
require 'opencv'
require 'tempfile'
require 'timeout'

module OpenCV
  # The version of OpenCV I'm running didn't have these constants defined
  # so I defined them them here as per opencv's documentation
  CV_CAP_PROP_FRAME_HEIGHT = 4
  CV_CAP_PROP_FRAME_WIDTH = 3
end

module Missile
  class Recorder
    include OpenCV
    include Magick

    def initialize(device_id)
      @device_id = device_id
    end

    def record(filename, record_delay, &block)
      # This is incredibly hacky, running out of time for this hackday
      # On a new thread save tmp png images. then compile them into a gif
      # This is a huge performance hit, but hey, this project is silly and
      # is only meant to run on a dedicated raspberry pi.
      #
      images = []
      capture = OpenCV::CvCapture.open(@device_id)
      capture.width = 400
      capture.height = 225

      recording = true
      puts 'Recording'
      # Start a new thread to record all of this
      t = Thread.new do
        sleep record_delay
        while recording == true
          puts 'Capturing Frame'
          capture.grab
          puts 'Retrieving Frame'
          frame = capture.retrieve
          tf = Tempfile.new(['missile', '.png'])
          puts "Storing it in file #{tf.path}"
          frame.save_image(tf.path)
          puts 'Storing location of image locally'
          images << tf
          puts 'Successfully saved image'
          sleep 0.1
        end
      end

      # Asynchronously call the code, then stop recording
      block.call
      recording = false
      puts 'Waiting for thread to finish'
      t.join

      gif = ImageList.new
      puts 'Processing'
      images.each do |img|
        editted_image = Magick::Image.read(img.path)[0]
        gif << editted_image.rotate(-90)
        File.delete(img.path)
      end

      gif.write(filename)
      filename
    end
  end
end
