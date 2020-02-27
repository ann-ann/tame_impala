# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'rss'
require 'readability'
require 'concurrent'
require 'pry'

class ImpalaCrawler
  class Error < StandardError; end
  class FeedNotFoundError < Error; end

  FEED_LINK_PATH = "link[type='application/rss+xml'], link[type='application/atom+xml']"

  def initialize(url, last)
    @url = url
    @last = last
    @feed_link, @feed = nil
  end

  def crawl_blogposts
    set_feed_link
    fetch_feed
    fetch_feed_items
  end

  private
  def set_feed_link
    blog_page = Nokogiri::HTML(URI.open(@url))

    @feed_link = blog_page.css(FEED_LINK_PATH).map{ |link| link[:href]}.first
    # If none found, raise.
    raise FeedNotFoundError.new('Could not find RSS or ATOM feed') unless @feed_link
  end

  def fetch_feed
    response = URI.open @feed_link
    @feed = RSS::Parser.parse(response)
  end

  def fetch_feed_items
    @feed.items.first(@last).map do |item|
      Concurrent::Future.execute do
        source = URI.open(feed_item_link(item)).read
        {
          title: clean_content(item.title.to_s),
          content: Readability::Document.new(source).content
        }
      end
    end.map(&:value!).compact
  end

  def feed_item_link(item)
    item.link.kind_of?(String) ? item.link : item.link.href
  end

  def clean_content(raw_html)
    html = raw_html.encode('UTF-8', invalid: :replace, undef: :replace, replace: '', universal_newline: true).gsub(/\P{ASCII}/, '')
    parser = Nokogiri::HTML(html, nil, Encoding::UTF_8.to_s)
    parser.xpath('//script')&.remove
    parser.xpath('//style')&.remove
    parser.xpath('//text()').map(&:text).join(' ')
  end
end
