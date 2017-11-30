require 'rubygems'
require 'redis'
require 'colorize'
require 'benchmark'

$redis = Redis.new

puts
puts 'Redis visits ranking demo'.upcase.green.bold
puts

TOTAL_VISITS_COUNT = 30_000
ITEMS_COUNT = 1_000
ITEM_PATH_PREFIX = '/articles/'
ZSET_NAME = 'visits-ranking'

elapsed = Benchmark.realtime do
  $redis.pipelined do
    TOTAL_VISITS_COUNT.times do |number|
      item_id = rand(1..ITEMS_COUNT)
      path = ITEM_PATH_PREFIX + item_id.to_s
      $redis.zincrby ZSET_NAME, 1, path
    end
  end
end

puts "#{TOTAL_VISITS_COUNT} fake visits across #{ITEMS_COUNT} unique URLs stored in Redis in #{elapsed.round(2)} seconds"
puts
puts 'Resulting ranking:'
puts

ranks = nil

elapsed = Benchmark.realtime do
  ranks = $redis.zrevrange ZSET_NAME, 0, 9, with_scores: true
end

ranks.each_with_index do |rank, index|
  print (index + 1).to_s.rjust(3, ' ')
  print ') '
  puts "#{rank[0]}: #{rank[1].to_i} visits".light_white
end

puts
puts "Ranking calculated in Redis in #{(elapsed * 1000).round(2)} miliseconds"
