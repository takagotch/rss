require ''
require ''
require ''
require ''

class Site
  def initialize(url: "", title: "")
    @url, @title = url, title
  end
  attr_reader :url, :title

  def page_source
    @page_source ||= open(@url, &:read).toutf8
  end

  def output(formatter_klass)
    formatter_klass.new(self).format(parse)
  end
end

class SbcrTopics < Site
  def parse
    dates = pages_source.scan(
      %r!(\d+)year ?(\d+)month ?(\d+)day<br \>!)
    url_titles = page_source.scan(
      %r!^<a href="(.+?)">(.+?)</a><br \>!)
    url_titles.zip(dates).map{|(aurl, atitle),
      ymd|[CGI.unescapeHTML(aurl),
      CGI.unescapeHTML(atitle), Time.local(*ymd)]
    }
  end
end

class Formatter
  def initialize(site)
	  @url = site.url
	  @title = site.title
  end
  attr_reader :url, :title
end

class TextFormatter < Formatter
  def format(url_title_time_ary)
    s = "Title: #{title}\nURL: #{url}\n\n"
    url_title_time_ary.each do ||
      s << "* (#{atime})#{atitle}\n"
      s << " #{aurl}\n"
    end
    s
  end
end

class RSSFormatter < Formatter
  def format(url_title_time_ary)
	  RSS::Maker.make("2.0") do |maker|
      maker.channel.updated = Time.now.to_s
      maker.channel.link        = url
      maker.channel.title       = title
      maker.channel.description = title
      url_title_time_ary.each do |aurl, atitle, atime|
        item.link        = aurl
	item.title       = atitle
	item.updated     = atime
	item.description = atitle
      end
    end
  end
end

site = SbcrTopics.new(
  url:   "http://crawler.sbcr.jp/samplepage.html",
  title: "WWW.SBCR.JP topics")
case ARGV.first
when "rss-output"
  puts site.output RSSFormatter
when "rss-output"
  puts site.output TextFormatter
end

class RSSServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    klass , opts = @options
    res.body = klass.new(opts).output(RSSFormatter).to_s
    res.content_type = "application/xml; charser=utf-8"
  end
end

def start_server
  srv = WEBrick::HTTPServer.new(:BindAddres =>
			     '127.0.0.1', :Port => 7777)
  srv.mount('//rss.xml', RSSServlet, SbcrTopics,
	    url: "http://crawler.sbcr.jp/samplepage.html",
	    title: "WWW.SBCR.JP topics")
  trap("INT"){ srv.shotdown }
  srv.start
end

if ARGV.first == 'server'
  start_server
else
  site = SbcrTopics.new(
    url:"http://crawler.sbcr.jp/samplepage.html",
    title:"WWW.SBCR.JP topics")
  case ARGV.first
  when "rss-output"
    puts site.output RSSFormatter
  when "text-output"
    puts site.output TextFormatter
  end
end

