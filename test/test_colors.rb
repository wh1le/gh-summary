require_relative "test_helper"

class TestColors < Minitest::Test
  def test_all_constants_defined
    %i[BOLD DIM CYAN YELLOW GREEN RED MAGENTA RESET].each do |constant|
      assert GhSummary::Colors.const_defined?(constant), "Missing constant: #{constant}"
    end
  end

  def test_all_constants_are_ansi_escape_sequences
    GhSummary::Colors.constants.each do |constant|
      value = GhSummary::Colors.const_get(constant)
      assert value.start_with?("\033["), "#{constant} is not an ANSI escape: #{value.inspect}"
    end
  end

  def test_reset_ends_formatting
    assert_equal "\033[0m", GhSummary::Colors::RESET
  end

  def test_can_be_included_in_a_class
    klass = Class.new { include GhSummary::Colors }
    instance = klass.new
    assert_equal GhSummary::Colors::BOLD, instance.class.const_get(:BOLD)
  end
end
