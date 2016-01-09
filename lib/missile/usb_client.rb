require_relative './command_payloads'
require 'libusb'
require 'logger'

module Missile
  class ConnectionError < StandardError; end

  class UsbClient
    PAYLOAD_START         = 0x02
    REQUEST_TYPE          = 0x21
    REQUEST               = 0x09
    STOP_BURNOUT_DURATION = 0.1
    START_BURNIN_DURATION = 0.1
    CONNECT_RETRY         = 10.0
    DEFAULT_FIRE_DELAY    = 3.5

    def initialize(vendor_id, product_id)
      @vendor_id = vendor_id
      @product_id = product_id
      @last_connected = 0.0
    end

    def left(duration = nil)
      log_command('LEFT', duration)
      run_command(CommandPayloads::Left, duration)
    end

    def right(duration = nil)
      log_command('RIGHT', duration)
      run_command(CommandPayloads::Right, duration)
    end

    def up(duration = nil)
      log_command('UP', duration)
      run_command(CommandPayloads::Up, duration)
    end

    def down(duration = nil)
      log_command('DOWN', duration)
      run_command(CommandPayloads::Down, duration)
    end

    def fire
      log_command('FIRE')
      run_command(CommandPayloads::Fire, DEFAULT_FIRE_DELAY)
    end

    def led_on
      run_command(CommandPayloads::LedOn)
    end

    def led_off
      run_command(CommandPayloads::LedOff)
    end

    def connect
      if Time.now.to_f - @last_connected > CONNECT_RETRY
        usb = LIBUSB::Context.new
        usb_device = usb.devices(idVendor: @vendor_id, idProduct: @product_id).first

        fail ConnectionError, 'Could not find USB device' if usb_device.nil?

        @device = usb_device.open
        @device.detach_kernel_driver(0) if @device.kernel_driver_active?(0)
      end
      @last_connected = Time.now.to_f
    end

    private

    def log_command(type, duration = nil)
      if duration.nil?
        puts "MISSILE: #{type}"
      else
        puts "MISSILE: #{type} for #{duration} seconds"
      end
    end

    def run_command(cmnd, duration = nil)
      # Sleep a little bit before every command
      sleep(START_BURNIN_DURATION)
      # Connect to the USB device
      connect
      # Send the command
      send_command(cmnd)
      if !duration.nil? && duration.to_f > 0.0
        # Sleep the amount if theres a duration
        sleep(duration.to_f)
        # Stop after the amount is slept
        send_command(CommandPayloads::Stop)
        # Sleep a little bit after a stop command
        sleep(STOP_BURNOUT_DURATION)
      end
    end

    def send_command(command)
      @device.control_transfer(
        bmRequestType: REQUEST_TYPE,
        bRequest: REQUEST,
        wValue: 0,
        wIndex: 0,
        dataOut: command,
        timeout: 0
      )
    end
  end
end
