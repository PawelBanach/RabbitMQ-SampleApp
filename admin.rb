#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'pry'
require './hospital_employee'

class Admin < HospitalEmployee
  def initialize
    @name = 'Admin'
    open('log.txt', 'a+') {|f| f.puts("\n\n\n#{Time.now.strftime('%c')} | Admin started") }
    setup_channel
    setup_queues
  end

  def setup_queues
    @admin_x = @channel.fanout('admin', auto_delete: true)
    @queue = @channel.queue('logs', durable: true, auto_delete: false)
    @queue.bind(@x, routing_key: '#').subscribe do |_, _, payload|
      time = Time.now.strftime('%c')
      open('log.txt', 'a+') {|f| f.puts("\n#{time} | \n#{payload}") }
      puts "\n#{time} | \n#{payload}"
    end

    loop { send_message }
  rescue Interrupt => _
    puts " > #{@name} finished job"
  end

  def send_message
    puts ' > Write information to all employees'
    message = STDIN.gets.chomp
    @admin_x.publish(message)
  end
end

Admin.new