require 'faraday'
require 'nokogiri'

def post_info(post_url)
  response = Faraday.get(post_url)
  post = Nokogiri::HTML.fragment(response.body)

  tweet = post.css('div.tweet[data-permalink-path=\'' + post_url.slice(19..-1) + '\']')
  tweet.css('div.js-tweet-text-container p a.u-hidden').remove
  text = tweet.css('div.js-tweet-text-container p').text
  likes = []

  li = tweet.css('div.js-tweet-details-fixer div.js-tweet-stats-container ul li[3]')
  li.css('a')[0..2].each do |a|
    link = 'https://twitter.com' + a.attribute('href')
    likes.push(link)
  end

  { 'text' => text, 'likes' => likes }
end

response = Faraday.get 'https://twitter.com/elonmusk'
elon_page = Nokogiri::HTML.fragment(response.body)
tweets_urls = []

# Add 3 last tweets addresses to Array `tweets_urls`
tweets_count = 0
elon_page.css('li.js-stream-item').each do |li|
  context = li.css('div div.context')
  # Take tweet's id if it original tweet(not pinned and not retweet)
  if context.children.length == 1
    tweet_id = li.css('div.tweet').attribute('data-tweet-id')
    tweets_urls.push('https://twitter.com/elonmusk/status/' + tweet_id)
    tweets_count += 1
  end
  break if tweets_count == 3
end

posts = [] # Array with full info about 3 tweets
(0..2).each { |i| posts.push(post_info(tweets_urls[i])) }

(0..2).each do |i|
  puts "Post " + (i+1).to_s + ":"
  puts(posts[i]['text'])
  puts 'Liked by:'
  (0..2).each do |j|
    puts('- ' + posts[i]['likes'][j])
  end
  puts('')
end
