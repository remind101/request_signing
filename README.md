# RequestSigning

An extensible implementation of [http request signing spec draft](https://tools.ietf.org/html/draft-cavage-http-signatures-08)
for Ruby HTTP clients and servers.

Supports the following algorithms:

* rsa-sha1
* rsa-sha256
* rsa-sha512
* dsa-sha1
* hmac-sha1
* hmac-sha256
* hmac-sha512

Integrates with the following libraries:

* rack
* net/http
* faraday

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request_signing'
gem 'request_signing-rack'
gem 'request_signing-faraday'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install request_signing request_signing-rack request_signing-faraday

## Usage

See [examples](./examples)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/remind101/request_signing.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

