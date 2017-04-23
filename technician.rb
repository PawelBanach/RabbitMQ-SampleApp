#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'pry'
require 'securerandom'
require './hospital_employee'

SPECIALIZATIONS = %w(knee ankle elbow)

class Technician < HospitalEmployee
  def initialize(specializations)
    @name = "Technician-#{SecureRandom.uuid[0,8]}"
    @specializations = specializations
    setup_channel
    setup_admin_queue
    listen_queues
  end

  def listen_queues
    @channel.prefetch(1)
    @specializations.each { |specialization| listen(specialization) }
    loop { sleep 500 }
  rescue Interrupt => _
    puts " > #{@name} finished job"
  end

  def listen(specialization)
    @queue = @channel.queue(specialization, durable: true, auto_delete: false)
    @queue.bind(@x, :routing_key => specialization).subscribe(manual_ack: true) do |delivery_info, properties, payload|
      patient = payload.split('|')[1].strip
      examination = delivery_info[:routing_key]
      result = EXAMINATION_RESULTS[rand(6)]
      puts " > Upcoming #{examination} examination for #{patient}  from: #{properties[:reply_to]}."

      puts ' > Making examination...'
      sleep rand(5) + 3

      @channel.acknowledge(delivery_info.delivery_tag, false)
      puts " > Examination finished, reply to #{properties[:reply_to]}.\n\n"
      @x.publish("#{@name}:\n   Patient: #{patient}\n   Examination: #{examination}\n   Result: #{result}",
                     routing_key: properties[:reply_to])
    end
  end
end

if ARGV.empty?
  abort " > Usage: #{$0} [knee] [ankle] [elbow]"
end

ARGV.each do |specialization|
  unless SPECIALIZATIONS.include? specialization
    abort " > Incorrect specialization #{specialization}. Valid specializations: #{SPECIALIZATIONS}"
  end
end

Technician.new(ARGV)
