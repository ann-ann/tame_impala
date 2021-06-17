q# TameImpala

This gem fetches posts/articles from an URL. You can use it either as a library or console app.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tame_impala'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tame_impala

## Usage

You can run this gem as a library:

```ruby
TameImpala.fetch_posts(url: 'https://blogs.dropbox.com/tech/', last: 1)
```

Argument ```last``` is optional, it determines how many articles to fetch and it defaults to 10 it's maximum(for now).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

While in development, it's convenient to run it from your terminal:

```bash
./exe/tame_impala 'https://blogs.dropbox.com/tech/' 1
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tame_impala. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/tame_impala/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TameImpala project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/tame_impala/blob/master/CODE_OF_CONDUCT.md).
