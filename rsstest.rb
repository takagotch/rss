require 'open-uri'

rss = RSS::Maker.make("2.0") do |marker|
  marker.channel.language = "en"

  maker.chnnel.author = "takagotch"

  maker.chnnel.updated = Time.now.to_s

  #...

end

