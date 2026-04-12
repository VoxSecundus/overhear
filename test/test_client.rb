# frozen_string_literal: true

require 'test_helper'

class TestClient < Minitest::Test
  TOKEN = 'valid_token'

  def test_invalid_token_raises_error
    stub_token_validation('invalid_token', valid: false)
    assert_raises(Overhear::InvalidTokenError) { Overhear::Client.new('invalid_token') }
  end

  def test_valid_token_sets_username
    stub_token_validation(TOKEN)
    client = Overhear::Client.new(TOKEN)

    assert_equal 'test_user', client.username
  end

  def test_valid_token_stored
    stub_token_validation(TOKEN)
    client = Overhear::Client.new(TOKEN)

    assert_equal TOKEN, client.token
  end

  def test_listens_returns_listens_service
    stub_token_validation(TOKEN)
    client = Overhear::Client.new(TOKEN)

    assert_instance_of Overhear::ListensService, client.listens
  end

  def test_user_returns_user_service
    stub_token_validation(TOKEN)
    client = Overhear::Client.new(TOKEN)

    assert_instance_of Overhear::UserService, client.user
  end

  def test_listens_is_memoised
    stub_token_validation(TOKEN)
    client = Overhear::Client.new(TOKEN)

    assert_same client.listens, client.listens
  end

  def test_user_is_memoised
    stub_token_validation(TOKEN)
    client = Overhear::Client.new(TOKEN)

    assert_same client.user, client.user
  end
end
