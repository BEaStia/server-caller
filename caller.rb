require_relative 'models/server'
require_relative 'models/server_status'
require 'concurrent/async'

class Caller
  attr_accessor :server
  include Concurrent::Async

  def initialize(server)
    self.server = server
  end

  def ping
    result = Net::Ping::HTTP.new(@server[:address])
    status = ServerStatus.new(server: @server.id, available: result.ping?, time: Time.now)
    status.duration = result.duration if result.ping?
    status.save
  end
end