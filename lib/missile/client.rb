require_relative './usb_client'
require_relative './recorder'

require 'net/https'
require 'uri'
require 'json'

module Missile
  class Client
    MISSILEQUEUE_BASE_URL = ENV.fetch('MISSILEQUEUE_BASE_URL', 'localhost:3000')
    MISSILEQUEUE_URL   = "#{MISSILEQUEUE_BASE_URL}/targets" # URL of application running
    GIF_FILE           = '/Users/peter/Desktop/out.gif' # Where to store the gif
    ZERO_LAT_BUFFER    = 0.5
    ZERO_LOFT_BUFFER   = 0.5
    MAX_LAT_DURATION   = 8.0
    SCAN_DURATION      = 4.5
    MAX_LOFT_DURATION  = 3.0
    RECORD_DELAY       = 0.6
    DEFAULT_VENDOR_ID  = 0x2123
    DEFAULT_PRODUCT_ID = 0x1010
    DEFAULT_CAMERA_ID  = ENV.fetch('CAMERA_ID', 1).to_i # Will need to be configured from machine to machine

    def initialize(vendor_id = DEFAULT_VENDOR_ID, product_id = DEFAULT_PRODUCT_ID, camera_device_id = DEFAULT_CAMERA_ID)
      @client = UsbClient.new(vendor_id, product_id)
      @camera_device_id = camera_device_id
      @current_lat_tt  = MAX_LAT_DURATION
      @current_loft_tt = MAX_LOFT_DURATION
    end

    def zero!
      @client.left(@current_lat_tt + ZERO_LAT_BUFFER)
      @client.down(@current_loft_tt + ZERO_LAT_BUFFER)
      @current_lat_tt = 0.0
      @current_loft_tt = 0.0
    end

    def point!(lat, loft, _record = false)
      lat = bound_lat(lat)
      loft = bound_loft(loft)

      if (lat != @current_lat_tt) || (loft != @current_loft_tt)
        zero!
        @client.right(lat) if lat > 0.0
        @client.up(loft) if loft > 0.0
      end

      @current_lat_tt = lat
      @current_loft_tt = loft
    end

    def record_room!
      unless @camera_device_id.nil?
        camera = Recorder.new(@camera_device_id)
        zero!
        camera.record(GIF_FILE, 1.0) do
          @client.right(SCAN_DURATION)
        end
      end
    end

    def fire!
      if @camera_device_id.nil?
        @client.fire
      else
        camera = Recorder.new(@camera_device_id)
        camera.record(GIF_FILE, RECORD_DELAY) do
          @client.fire
        end
      end
    end

    def shoot_targets
      # Fail fast if no connection to USB
      @client.connect
      # Turn on LED whenever connecting to the server
      @client.led_on
      uri = URI.parse(MISSILEQUEUE_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      @client.led_off
      JSON.parse(response.body).map do |jj|
        if jj['name'] == 'scan'
          puts 'Recording room'
          record_room!
        else
          puts 'Pointing turret'
          point!(jj['lat_tt'].to_f, jj['loft_tt'].to_f)
          puts 'Firing turret'
          fire!
        end

        # Hackday presentations are soon, don't have time to properly do a
        # Net::HTTP request to upload the gif. Any rubyists out there are going
        # to get real mad at me for doing this, as they should. yolo.
        `curl -F animation=@#{GIF_FILE} -X POST #{MISSILEQUEUE_BASE_URL}/reaction`

        puts 'Finished Uploading Reaction, deleting file'
        File.delete(GIF_FILE)
      end
    end

    private

    def bound_lat(lat)
      [[0.0, lat.to_f].max, MAX_LAT_DURATION].min
    end

    def bound_loft(loft)
      [[0.0, loft.to_f].max, MAX_LOFT_DURATION].min
    end
  end
end
