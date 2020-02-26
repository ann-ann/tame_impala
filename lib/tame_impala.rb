require 'tame_impala/version'
require 'nokogiri'  
require 'open-uri'
require 'rss'
require 'readability'
require 'concurrent'

module TameImpala
  class Error < StandardError; end
  RSS_LINK_PATH = "link[type='application/rss+xml']"
  ATOM_LINK_PATH = "link[type='application/atom+xml']"

  def self.crawl_blogposts(url:, last: 10)
    type = :rss
    blog_page = Nokogiri::HTML(URI.open(url)) 
    # TODO: handle link search more efficient(or add ability to load comments link) 
    # TODO: check regex
    feed_link = blog_page.css(RSS_LINK_PATH)
    if feed_link.empty?
      feed_link = blog_page.css(ATOM_LINK_PATH) 
      type = :atom
    end

    # handle error if no feed link found
    response =  URI.open(feed_link[0]['href'])
    feed = RSS::Parser.parse response

    feed.items.last(last).map do |item|
      Concurrent::Future.execute do
        link = type === :rss ? clean_content(item.link.to_s) : item.link.href
        source = URI.open(link).read

        { title: clean_content(item.title.to_s),
          content: Readability::Document.new(source).content
        }
      end
    end.map(&:value!).compact
  end

  private
  def self.clean_content(raw_html)
    html = raw_html.encode('UTF-8', invalid: :replace, undef: :replace, replace: '', universal_newline: true).gsub(/\P{ASCII}/, '')
    parser = Nokogiri::HTML(html, nil, Encoding::UTF_8.to_s)
    parser.xpath('//script')&.remove
    parser.xpath('//style')&.remove
    parser.xpath('//text()').map(&:text).join(' ')
  end
end

