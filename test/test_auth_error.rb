require_relative "test_helper"

class TestAuthError < Minitest::Test
  def test_inherits_from_standard_error
    assert_operator GhSummary::AuthError, :<, StandardError
  end

  def test_accepts_custom_message
    error = GhSummary::AuthError.new("custom message")
    assert_equal "custom message", error.message
  end

  def test_can_be_raised_and_rescued
    assert_raises(GhSummary::AuthError) do
      raise GhSummary::AuthError, "not authenticated"
    end
  end
end
