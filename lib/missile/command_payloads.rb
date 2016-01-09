require_relative './command_codes'
require_relative './command_types'

module Missile
  module CommandPayloads
    def self.pack(type, code)
      [type, code, 0, 0, 0, 0, 0, 0].pack('CCCCCCCC')
    end

    Left   = pack(CommandTypes::Motion, CommandCodes::Left)
    Right  = pack(CommandTypes::Motion, CommandCodes::Right)
    Up     = pack(CommandTypes::Motion, CommandCodes::Up)
    Down   = pack(CommandTypes::Motion, CommandCodes::Down)
    Fire   = pack(CommandTypes::Motion, CommandCodes::Fire)
    Stop   = pack(CommandTypes::Motion, CommandCodes::Stop)
    LedOn  = pack(CommandTypes::Led,    CommandCodes::LedOn)
    LedOff = pack(CommandTypes::Led,    CommandCodes::LedOff)
  end
end
