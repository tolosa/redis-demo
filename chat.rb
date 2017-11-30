require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

CHANNEL_NAME = 'redis-chat-demo'
PROMPT = "\r> "

$listener = Redis.new
$client = Redis.new

puts
puts 'Redis chat client demo'.upcase.green.bold
puts

username = ''
valid_username = false

until valid_username
  print 'Enter you username: '
  username = gets.chomp
  valid_username = username.length > 0
  puts 'Invalid username, enter it again' unless valid_username
end

puts
puts "Joined chat channel '#{CHANNEL_NAME.bold}' as '#{username.bold}'"
puts 'Just type and press enter to send a message'
puts 'Press CTRL + C to exit program'
puts

Thread.new do
  $listener.subscribe CHANNEL_NAME do |on|
    on.message do |channel, message|
      data = JSON.parse(message)
      sender = data['username']
      puts "\r#{sender.magenta.bold}: #{data['message']}" if sender != username
      print PROMPT
    end
  end
end

loop do
  print PROMPT
  message = gets.chomp
  $client.publish CHANNEL_NAME, { username: username, message: message }.to_json
end
