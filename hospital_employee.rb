class HospitalEmployee
  EXAMINATION_RESULTS = %w(Dying VeryBad Bad Fine Healthy VeryHealthy)

  def setup_admin_queue
    @admin_queue = @channel.queue('', durable: true, auto_delete: false)
    @admin_x = @channel.fanout('admin', auto_delete: true)
    @admin_queue.bind(@admin_x).subscribe do |_, _, payload|
      puts "\n > ! Admin information !\n#{payload}\n"
    end
  end

  def setup_channel
    @connection = Bunny.new
    @connection.start

    @channel = @connection.create_channel
    @x = @channel.topic('examination')
    puts " > #{@name} setup finished"
  end
end