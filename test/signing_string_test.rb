require 'test_helper'

class SigningStringTest < Test
  test "replaces (request-target) with lowercased :method and :path" do
    req = RequestSigning::GenericHTTPRequest.new(
      "GET",
      "/foo",
      "host" => ["example.org"],
      "date" => ["Mon, 23 Oct 2017 00:00:00 GMT"]
    )
    headers_list = %w[(request-target) host date]
    result = RequestSigning.make_string_for_signing(headers_list, req)
    assert_equal(<<~STR.chomp, result)
      (request-target): get /foo
      host: example.org
      date: Mon, 23 Oct 2017 00:00:00 GMT
    STR
  end

  test "(request-target) includes url query params" do
    req = RequestSigning::GenericHTTPRequest.new(
      "GET",
      "/foo?qux=baz",
      "host" => ["example.org"],
      "date" => ["Mon, 23 Oct 2017 00:00:00 GMT"]
    )
    headers_list = %w[(request-target) host date]
    result = RequestSigning.make_string_for_signing(headers_list, req)
    assert_equal(<<~STR.chomp, result)
      (request-target): get /foo?qux=baz
      host: example.org
      date: Mon, 23 Oct 2017 00:00:00 GMT
    STR
  end

  test "concatenates headers in specified order" do
    req = RequestSigning::GenericHTTPRequest.new(
      "GET",
      "/foo?qux=baz",
      "host" => ["example.org"],
      "date" => ["Mon, 23 Oct 2017 00:00:00 GMT"]
    )
    headers_list = %w[(request-target) date host]
    result = RequestSigning.make_string_for_signing(headers_list, req)
    assert_equal(<<~STR.chomp, result)
      (request-target): get /foo?qux=baz
      date: Mon, 23 Oct 2017 00:00:00 GMT
      host: example.org
    STR
  end

  test "concatenates multiple header field values as they appear in request" do
    req = RequestSigning::GenericHTTPRequest.new(
      "GET",
      "/foo",
      "x-my-header" => ["foo", "bar"],
      "host" => ["example.org"],
      "date" => ["Mon, 23 Oct 2017 00:00:00 GMT"],
    )
    headers_list = %w[(request-target) host date x-my-header]
    result = RequestSigning.make_string_for_signing(headers_list, req)
    assert_equal(<<~STR.chomp, result)
      (request-target): get /foo
      host: example.org
      date: Mon, 23 Oct 2017 00:00:00 GMT
      x-my-header: foo, bar
    STR
  end

  test "truncates header field value leading and trailing spaces" do
    req = RequestSigning::GenericHTTPRequest.new(
      "GET",
      "/foo",
      "x-my-header" => [" foo "],
      "host" => ["example.org"],
      "date" => ["Mon, 23 Oct 2017 00:00:00 GMT"],
    )
    headers_list = %w[(request-target) host date x-my-header]
    result = RequestSigning.make_string_for_signing(headers_list, req)
    assert_equal(<<~STR.chomp, result)
      (request-target): get /foo
      host: example.org
      date: Mon, 23 Oct 2017 00:00:00 GMT
      x-my-header: foo
    STR
  end
end


