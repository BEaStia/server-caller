# frozen_string_literal: true

require 'net/ping'
require 'sequel'
DB = Sequel.connect('sqlite://blog.db')

require_relative 'models/server'
require_relative 'models/server_status'
require_relative 'caller'
require 'concurrent'
require 'thread'

class Application
  attr_accessor :servers_to_delete

  def initialize
    create_servers_table
    create_server_values_table
    check_servers
    self.servers_to_delete = []
  end

  def remove_server(url)
    servers_to_delete.push(url)
    Server.where('address=', url).delete
  end

  def add_server(url)
    Server.create(address: url)
    check_server(Caller.new(caller))
  end

  def check_servers

    Server.each do |server|
      check_server(Caller.new(server))
    end
  end

  def check_server(caller)
    Concurrent::ScheduledTask.execute(5) do
      unless @servers_to_delete.include?(caller.server[:address])
        caller.async.ping
        check_server(caller)
      end
    end
  end

  private

  def create_servers_table
    unless DB.table_exists?(:servers)
      DB.create_table(:servers) do
        primary_key :id
        String :address
        one_to_many :server_values
      end
    end
  end

  def create_server_values_table
    unless DB.table_exists?(:server_statuses)
      DB.create_table :server_statuses do
        many_to_one :server
        DateTime    :time
        Float       :duration
        Boolean     :available
      end
    end
  end
end
