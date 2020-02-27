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

  RSS_LINK_PATH = "link[type='application/rss+xml']"
  ATOM_LINK_PATH = "link[type='application/atom+xml']"

  def initialize(url, last)
    @url = url
    @last = last
    @type, @feed_link, @feed = nil
  end

  def crawl_blogposts
    set_feed_link
    fetch_feed
    fetch_feed_items
  end

  private
  def set_feed_link
    blog_page = Nokogiri::HTML(URI.open(@url))

    # Check whether RSS feed exists, we prefer RSS if both RSS and ATOM are available.
    feed_path = blog_page.css(RSS_LINK_PATH)
    @type = :rss

    # Fall back to ATOM if RSS isn't available.
    if feed_path.empty?
      @feed_link = blog_page.css(ATOM_LINK_PATH)
      @type = :atom
    end

    # If none found, raise.
    if feed_path.empty?
      raise FeedNotFoundError.new('Could not find RSS or ATOM feed')
    end
    @feed_link = feed_path.first['href']
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
    case @type
      when :rss  then clean_content(item.link.to_s)
      when :atom then item.link.href
    end
  end

  def clean_content(raw_html)
    html = raw_html.encode('UTF-8', invalid: :replace, undef: :replace, replace: '', universal_newline: true).gsub(/\P{ASCII}/, '')
    parser = Nokogiri::HTML(html, nil, Encoding::UTF_8.to_s)
    parser.xpath('//script')&.remove
    parser.xpath('//style')&.remove
    parser.xpath('//text()').map(&:text).join(' ')
  end
end
