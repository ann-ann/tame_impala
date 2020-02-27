# frozen_string_literal: true

require 'tame_impala/version'
require 'tame_impala/impala_crawler'

module TameImpala
  def self.fetch_posts(url:, last: 10)
    ImpalaCrawler.new(url, last).crawl_blogposts
  end
end
