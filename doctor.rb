#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'pry'
require 'securerandom'
require './hospital_employee'

SPECIALIZATIONS = %w(knee ankle elbow)

class Doctor < HospitalEmployee

  def initialize(patient, examination_type)
    @name = "Doctor-#{SecureRandom.uuid[0,8]}"
    @patient = patient
    @examination_type = examination_type
    @lock      = Mutex.new
    @condition = ConditionVariable.new

    setup_channel
    setup_admin_queue
    make_and_bind_to_reply_queue
    send_examination_request
  end

  def make_and_bind_to_reply_queue
    @queue = @channel.queue('', durable: true, auto_delete: true)
    @queue.bind(@x, routing_key: @name).subscribe do |_, _, payload|
      @lock.synchronize{ @condition.signal }
      puts " > Response from #{payload}"
    end
  end

  def send_examination_request
    @x.publish("#{@name}: \n   Patient | #{@patient} | \n   Examination: #{@examination_type}",
               routing_key: @examination_type,
               reply_to: @name)
    @lock.synchronize{ @condition.wait(@lock)}
  end
end

abort "  > Usage: #{$0} <patient> <ankle|knee|elbow>" if ARGV.length != 2
abort "  > Not correct examination type: #{ARGV[1]}," unless SPECIALIZATIONS.include? ARGV[1]

Doctor.new(ARGV[0], ARGV[1])