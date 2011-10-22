# coding: UTF-8

require 'net/http'
require 'uri'
require 'open-uri'

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

  SRC_URL = "http://www.lanacion.com.ar/humor/macanudo"

  attr_reader :post

  def initialize
    @post = {
      :type => 'photo', :state => 'published', :format => 'html',
      :tags => 'liniers,macanudo', :group => 'macanudo-liniers.tumblr.com'
    }
  end

  def get_post
    html_doc = Nokogiri::HTML(open(SRC_URL))
    image_src = html_doc.css("a[alt='Liniers - Macanudo'] img").first['src'].gsub(/w318/,'')
    if !image_src.nil? && image_src != ""
      @post.merge!({
        :source => image_src,
        :caption => "Macanudo #{Date.today.strftime("%d / %m / %Y")} - <a href=\"http://www.lanacion.com.ar/humor\">Por Liniers</a>"
      })
      puts "Image from today found"
      return @post
    end
  rescue
    puts "Exception raised when trying to get the image"
    puts $!
    return false
  end

  def update_with_post
    return if @post[:source].nil?
    puts "Publishing..."
    tumblr = Tumblr.new(ENV['tumblr_email'], ENV['tumblr_password'], 'macanudo-liniers')
    response = tumblr.publish_photo(@post)
    puts response.inspect
  end

end