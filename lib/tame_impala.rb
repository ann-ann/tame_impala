# frozen_string_literal: true

require 'tame_impala/version'
require 'nokogiri'
require 'open-uri'
require 'rss'
require 'readability'
require 'concurrent'
require 'pry'

module TameImpala
  class Error < StandardError; end
  class FeedNotFoundError < Error; end

  RSS_LINK_PATH = "link[type='application/rss+xml']"
  ATOM_LINK_PATH = "link[type='application/atom+xml']"

  def self.crawl_blogposts(url:, last: 10)
    blog_page = Nokogiri::HTML(URI.open(url))

    # Check whether RSS feed exists, we prefer RSS if both RSS and ATOM are available.
    feed_link = blog_page.css(RSS_LINK_PATH)
    type = :rss

    # Fall back to ATOM if RSS isn't available.
    if feed_link.empty?
      feed_link = blog_page.css(ATOM_LINK_PATH)
      type = :atom
    end

    # If none found, raise.
    if feed_link.empty?
      raise FeedNotFoundError.new("Could not find RSS or ATOM feed")
    end

    response = URI.open(feed_link[0]['href'])
    feed = RSS::Parser.parse(response)

    feed.items.first(last).map do |item|
      Concurrent::Future.execute do
        link = case type
        when :rss  then clean_content(item.link.to_s)
        when :atom then item.link.href
        end
        source = URI.open(link).read

        {
          title: clean_content(item.title.to_s),
          content: Readability::Document.new(source).content
        }
      end
    end.map(&:value!).compact
  end

  def self.clean_content(raw_html)
    html = raw_html.encode('UTF-8', invalid: :replace, undef: :replace, replace: '', universal_newline: true).gsub(/\P{ASCII}/, '')
    parser = Nokogiri::HTML(html, nil, Encoding::UTF_8.to_s)
    parser.xpath('//script')&.remove
    parser.xpath('//style')&.remove
    parser.xpath('//text()').map(&:text).join(' ')
  end
  private_class_method :clean_content 
end
