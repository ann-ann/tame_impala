RSpec.describe TameImpala do
  let(:rss_client) { ImpalaCrawler.new('https://blogs.dropbox.com/tech/', 10) }
  let(:atom_client) { ImpalaCrawler.new('https://product.hubspot.com/blog/topic/engineering', 3) }
  let(:no_client) { ImpalaCrawler.new('https://google.com', 1) }

  it "has a version number" do
    expect(TameImpala::VERSION).not_to be nil
  end

  describe '#fetch_posts' do
    it 'returns the correct posts from RSS feed' do
      VCR.use_cassette('rss_blog') do
        result = rss_client.crawl_blogposts

        expect(result).to be_an_instance_of(Array)
        expect(result.size).to eq(10)

        expect(result.first[:title]).to eq('Dropbox bug bounty program has paid out over $1,000,000')
      end
    end

    it 'returns the correct posts from Atom feed' do
      VCR.use_cassette('atom_blog') do
        result = atom_client.crawl_blogposts

        expect(result).to be_an_instance_of(Array)
        expect(result.size).to eq(3)

        expect(result.first[:title]).to eq('Name Dropping: Kelsey Steinbeck, Director of Software Engineering at Indigo')
      end
    end

    it 'raises error if no rss/atom link found' do
      VCR.use_cassette('no_blog') do
        expect{no_client.crawl_blogposts}.to raise_error(ImpalaCrawler::FeedNotFoundError, 'Could not find RSS or ATOM feed') 
      end
    end
  end
end
