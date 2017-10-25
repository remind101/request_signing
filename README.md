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

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request_signing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install request_signing

## Usage

### Net::HTTP

    key_store = RequestSigning::KeyStores::Static.new(
      "app_1.v1" => ENV["APP_1_PRIVATE_KEY"],
      "app_2.v1" => ENV["APP_2_PRIVATE_KEY"],
    )
    req = Net::HTTP::Get.new("/foo?bar=baz")
    req["Date"] = "Thu, 05 Jan 2014 21:31:40 GMT"
    req["Signature"] =
      @signer.create_signature!(req, key_id: "app_1.v1", algorithm: "rsa-sha256", headers: %w[(request-target) date host])
    Net::HTTP.start("http://example.com", 80) do |http|
      response = http.request(req)
    end

### Rack

Default:

    key_store = RequestSigning::KeyStores::Static.new(
      "app_1.v1" => ENV["APP_1_PUBKEY"],
      "app_2.v1" => ENV["APP_2_PUBKEY"],
    )
    use RequestSigning::Rack::Middleware, key_store: key_store

With custom error handler:

    key_store = RequestSigning::KeyStores::Static.new(
      "app_1.v1" => ENV["APP_1_PUBKEY"],
      "app_2.v1" => ENV["APP_2_PUBKEY"],
    )
    logger = Logger.new(STDOUT)

    use RequestSigning::Rack::Middleware, key_store: key_store do |error, env, app|
      case error
      when RequestSigning::KeyNotFound, RequestSigning::MissingSignatureHeader
        # Useful during transition period while some clients still don't sign requests
        logger.debug("skipping signature verification: #{error}")
        app.call(env)
      else
        logger.error(error)
        [401, { "Content-Type" => "application/json" }, [%q({"error": "signature verification error"})]]
      end
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/remind101/request_signing.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

