require 'test_helper'

class ParamterParserTest < Test
  def setup
    @parser = RequestSigning::ParameterParser.new
  end

  HEADERS = "(request-target) host date content-type digest content-length"

  SIGNATURE = <<~STR.gsub(/\n/, "")
    jgSqYK0yKclIHfF9zdApVEbDp5eqj8C4i4X76pE+XHoxugXv7q
    nVrGR+30bmBgtpR39I4utq17s9ghz/2QFVxlnToYAvbSVZJ9ulLd1HQBugO0j
    Oyn9sXOtcN7uNHBjqNCqUsnt0sw/cJA6B6nJZpyNqNyAXKdxZZItOuhIs78w=
  STR

  test "parses keyId, algorithm, headers, signature" do
    str = strip_newlines(<<~STR)
      keyId="Test",
      algorithm="rsa-sha256",
      headers="(request-target) host date content-type digest content-length",
      signature="#{SIGNATURE}"
    STR
    result = @parser.parse(str)
    assert_equal "Test", result.key_id
    assert_equal "rsa-sha256", result.algorithm
    assert_equal %w[(request-target) host date content-type digest content-length], result.headers
    assert_equal SIGNATURE, result.signature
  end

  test "requires keyId" do
    [
      %Q[algorithm="rsa-sha256",headers="#{HEADERS}",signature="#{SIGNATURE}"],
      %Q[keyId="",algorithm="rsa-sha256",headers="#{HEADERS}",signature="#{SIGNATURE}"]
    ].each do |str|
      err = assert_raises(RequestSigning::BadSignatureParameters, str) do
        @parser.parse(str)
      end
      assert_match(/keyId/, err.message, str)
    end
  end

  test "requires algorithm" do
    [
      %Q[keyId="Test",headers="#{HEADERS}",signature="#{SIGNATURE}"],
      %Q[keyId="Test",algorithm="",headers="#{HEADERS}",signature="#{SIGNATURE}"]
    ].each do |str|
      err = assert_raises(RequestSigning::BadSignatureParameters, str) do
        @parser.parse(str)
      end
      assert_match(/algorithm/, err.message, str)
    end
  end

  test "requires signature" do
    [
      %Q[keyId="Test",algorithm="rsa-sha256",headers="#{HEADERS}"],
      %Q[keyId="Test",algorithm="rsa-sha256",headers="#{HEADERS}",signature=""]
    ].each do |str|
      err = assert_raises(RequestSigning::BadSignatureParameters, str) do
        @parser.parse(str)
      end
      assert_match(/signature/, err.message, str)
    end
  end

  test "keyId may contain spaces and escaped quotes" do
    {
      %Q[keyId="Test Test",algorithm="rsa-sha256",headers="#{HEADERS}",signature="#{SIGNATURE}"]       => "Test Test",
      %Q[keyId="Test \\"Test\\"",algorithm="rsa-sha256",headers="#{HEADERS}",signature="#{SIGNATURE}"] => "Test \"Test\"",
      %Q[keyId=" ",algorithm="rsa-sha256",headers="#{HEADERS}",signature="#{SIGNATURE}"]               => " ",
    }.each do |str, key_id|
      result = @parser.parse(str)
      assert_equal key_id, result.key_id, str
    end
  end

  test "lowercases headers" do
    str = %Q[keyId="Test",algorithm="rsa-sha256",headers="(request-target) Foo-Bar Baz",signature="#{SIGNATURE}"]
    result = @parser.parse(str)
    assert_equal %w[(request-target) foo-bar baz], result.headers
  end

  test "when repeated, takes last field value into account" do
    str = %Q[keyId="Test",algorithm="rsa-sha256",keyId="Test2",headers="(request-target) Foo-Bar Baz",signature="#{SIGNATURE}"]
    result = @parser.parse(str)
    assert_equal "Test2", result.key_id
  end

  test "raises on malformed string" do
    [
      %Q[keyId=,algorithm="rsa-sha256",headers="(request-target) Foo-Bar Baz",signature="#{SIGNATURE}"],
      %Q[keyId="Test" algorithm="rsa-sha256" headers="(request-target) Foo-Bar Baz" signature="#{SIGNATURE}"],
      %Q[keyId=Test,algorithm=rsa-sha256,headers="(request-target) Foo-Bar Baz",signature="#{SIGNATURE}"],
    ].each do |str|
      assert_raises RequestSigning::BadSignatureParameters, str do
        @parser.parse(str)
      end
    end
  end

  test "defaults headers to date" do
    str = %Q[keyId="Test",algorithm="rsa-sha256",keyId="Test2",signature="#{SIGNATURE}"]
    result = @parser.parse(str)
    assert_equal ["date"], result.headers
  end

  test "ignores unknown parameters" do
    str = %Q[keyId="Test",algorithm="rsa-sha256",keyId="Test2",signature="#{SIGNATURE}",foo="bar"]
    @parser.parse(str)
  end

  def strip_newlines(str)
    str.gsub(/\n/, "")
  end
end

