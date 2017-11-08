require 'test_helper'
require 'request_signing/ssm'

class SSMKeyStoreTest < Test
  def setup
    super
    @ssm = Aws::SSM::Client.new(stub_responses: {
      get_parameters_by_path: { parameters: [{ name: "id", type: "String", value: "key" }] }
    })
    @store = RequestSigning::KeyStores::SSM.with_ssm_path(ssm_client: @ssm, path: "/myapp/signing_keys")
  end

  test "#fetch returns a key" do
    assert_equal "key", @store.fetch("id")
  end

  test "#fetch raises KeyNotFound" do
    err = assert_raises(RequestSigning::KeyNotFound) do
      @store.fetch("wat")
    end
    assert_equal "wat", err.key_id
    assert_match(/wat/, err.message)
  end

  test "#key? returns true for existing key" do
    assert @store.key?("id")
  end

  test "#key? returns false for unknown key" do
    refute @store.key?("wat")
  end

  test "retrieves results from multiple pages" do
    @ssm.stub_responses(:get_parameters_by_path, [
      { parameters: [{ name: "id", type: "String", value: "key" }], next_token: "foo" },
      { parameters: [{ name: "id2", type: "String", value: "key2" }], next_token: "" },
    ])
    assert @store.key?("id")
    assert @store.key?("id2"), "expected store to retrieve second page"
  end

  test "#load! eager loads keys" do
    @store.load!
    @ssm.stub_responses(:get_parameters_by_path, RuntimeError.new("should not have queried SSM"))
    @store.key?("id")
    @store.fetch("id")
  end

  test "accepts custom ssm get_parameters_by_path options" do
    custom_ssm_options = {
      path: "/test",
      recursive: false,
      with_decryption: true,
      parameter_filters: [
        { key: "tag:public_key" }
      ]
    }
    sent_ssm_options = nil
    @ssm.stub_responses(:get_parameters_by_path, ->(ctx) do
      sent_ssm_options = ctx.params.dup
      @ssm.stub_data(:get_parameters_by_path)
    end)
    store = RequestSigning::KeyStores::SSM.with_ssm_options(ssm_client: @ssm, ssm_options: custom_ssm_options)
    store.load!
    assert_operator custom_ssm_options, :<=, sent_ssm_options
  end
end

