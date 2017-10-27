require 'test_helper'

class StaticKeyStoreTest < Test
  test "#fetch returns a key" do
    store = RequestSigning::KeyStores::Static.new("id" => "key")
    assert_equal "key", store.fetch("id")
  end

  test "#fetch raises KeyNotFound" do
    store = RequestSigning::KeyStores::Static.new("id" => "key")
    err = assert_raises(RequestSigning::KeyNotFound) do
      store.fetch("wat")
    end
    assert_match(/wat/, err.message)
  end

  test "#key? returns true for existing key" do
    store = RequestSigning::KeyStores::Static.new("id" => "key")
    assert store.key?("id")
  end

  test "#key? returns false for unknown key" do
    store = RequestSigning::KeyStores::Static.new("id" => "key")
    refute store.key?("wat")
  end

  test ".from_string makes an instance from string" do
    store = RequestSigning::KeyStores::Static.from_string("key1:secret1,key2:secret2")
    assert_equal "secret1", store.fetch("key1")
    assert_equal "secret2", store.fetch("key2")
  end

  test ".from_string makes raises MalformedKeysString" do
    assert_raises(RequestSigning::MalformedKeysString) do
      RequestSigning::KeyStores::Static.from_string("key1:secret1,wat")
    end
  end
end
