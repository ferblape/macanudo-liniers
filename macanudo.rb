# coding: UTF-8

require 'net/http'
require 'uri'

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

class Tumblr
  attr_reader :options
  def initialize(email, password, blog)
    @options = {:email => email, :password => password, :group => blog}
  end

  def publish_photo(options)
    @options = @options.merge(options).merge(:type => 'photo')

    uri = URI.parse("http://www.tumblr.com/api/write")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(@options)
    http.request(request)
  end
end

# Fetch images from Macanudo comic and post them in tumblr
# macanudo-liniers.tumblr.com
class Macanudo

  FEED = "http://feeds.feedburner.com/Autoliniers"

  attr_reader :last_entry

  def initialize
    @last_entry = {
      :type => 'photo', :state => 'published', :format => 'html',
      :tags => 'liniers,macanudo', :group => 'macanudo-liniers.tumblr.com'
    }
  end

  def get_last_entry
    feed = Atom::Feed.load_feed(URI.parse(FEED))
    feed.each_entry do |entry|
      if entry.published.to_date == Date.today
        html_doc = Nokogiri::HTML(entry.content)
        image_src = html_doc.css("img[src*=bucket]").first['src']
        if !image_src.nil? && image_src != ""
          @last_entry.merge!({
            :source => image_src,
            :caption => "Macanudo #{Date.today.strftime("%d / %m / %Y")} - <a href=\"http://www.lanacion.com.ar/humor\">Por Liniers</a>"
          })
          return true
        end
      end
    end
    return false
  end

  def update_last_entry
    return if @last_entry[:source].nil?
    tumblr = Tumblr.new(ENV['tumblr_email'], ENV['tumblr_password'], 'macanudo-liniers')
    tumblr.publish_photo(@last_entry)
  end

end