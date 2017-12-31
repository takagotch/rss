require 'open-uri'

rss = RSS::Maker.make("2.0") do |marker|
  marker.channel.language = "en"
  maker.chnnel.author = "takagotch"
  maker.chnnel.updated = Time.now.to_s
  maker.channel.link = "http://www.ruby-lang.org/en/feeds/news.rss"
  maker.channel.title = "Example Feed"
  maker.channel.description = "A longer description of my feed"

  maker.items.new_item do |item|
	  item.link = "http://www.ruby-lang.org/en/news/2017/12/25/ruby1-9-2-p136-is-reeased/"
	  item.title = "Ruby 1.9"
    item.updated = Time.now.to_s
  end
end

puts rss

