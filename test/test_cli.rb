require_relative "test_helper"

class TestCLI < Minitest::Test
  include GhSummary::Colors

  def setup
    @cli = TestCLIRecorder.new
  end

  # ── left_padding ───────────────────────────────────

  def test_left_padding_default
    result = @cli.send(:left_padding, "hello")
    assert_equal "  hello", result
  end

  def test_left_padding_custom_spacing
    result = @cli.send(:left_padding, "hello", 6)
    assert_equal "      hello", result
  end

  def test_left_padding_zero
    result = @cli.send(:left_padding, "hello", 0)
    assert_equal "hello", result
  end

  # ── divider ────────────────────────────────────────

  def test_divider_outputs_60_dashes
    @cli.divider
    output = @cli.printed
    assert_includes output, "─" * 60
    assert_includes output, DIM
    assert_includes output, RESET
  end

  # ── header ─────────────────────────────────────────

  def test_header_includes_divider_and_text
    @cli.header(GREEN, "Test")
    assert_equal 2, @cli.lines.size
    assert_includes @cli.lines[0], "─" * 60
    assert_includes @cli.lines[1], "Test"
    assert_includes @cli.lines[1], BOLD
    assert_includes @cli.lines[1], GREEN
  end

  # ── item ───────────────────────────────────────────

  def test_item_outputs_repo_title_and_url
    @cli.item("owner/repo", "Fix bug", "https://example.com")
    assert_equal 2, @cli.lines.size
    assert_includes @cli.lines[0], "owner/repo — Fix bug"
    assert_includes @cli.lines[1], "https://example.com"
  end

  def test_item_indentation
    @cli.item("repo", "title", "url")
    assert @cli.lines[0].start_with?("    ")
    assert @cli.lines[1].start_with?("      ")
  end

  # ── sub_item ───────────────────────────────────────

  def test_sub_item_indentation
    @cli.sub_item("detail")
    assert @cli.lines[0].start_with?("      detail")
  end

  # ── group ──────────────────────────────────────────

  def test_group_indentation
    @cli.group("label")
    assert @cli.lines[0].start_with?("    label")
  end

  # ── count ──────────────────────────────────────────

  def test_count_format
    @cli.count(5, "pending")
    output = @cli.printed
    assert_includes output, "(5 pending)"
    assert_includes output, DIM
  end

  # ── empty ──────────────────────────────────────────

  def test_empty_includes_text_and_dim
    @cli.empty("Nothing here")
    output = @cli.printed
    assert_includes output, "Nothing here"
    assert_includes output, DIM
  end

  # ── success ────────────────────────────────────────

  def test_success_includes_text_and_green
    @cli.success("All good")
    output = @cli.printed
    assert_includes output, "All good"
    assert_includes output, GREEN
  end

  # ── error ──────────────────────────────────────────

  def test_error_captures_message
    @cli.error("Something broke")
    assert_equal 1, @cli.error_lines.size
    assert_includes @cli.error_lines[0], "Something broke"
  end

  def test_error_does_not_write_to_stdout
    @cli.error("fail")
    assert_empty @cli.lines
  end

  # ── banner ─────────────────────────────────────────

  def test_banner_includes_title_and_colors
    @cli.banner
    output = @cli.printed
    assert_includes output, "GitHub Summary"
    assert_includes output, BOLD
    assert_includes output, CYAN
  end

  # ── table ──────────────────────────────────────────

  def test_table_renders_header_and_rows
    @cli.table(%w[Name Type], [%w[foo A], %w[bar B]])
    assert_equal 3, @cli.lines.size
    assert_includes @cli.lines[0], "Name"
    assert_includes @cli.lines[0], DIM
    assert_includes @cli.lines[1], "foo"
    assert_includes @cli.lines[2], "bar"
  end

  def test_table_pads_to_widest_cell
    @cli.table(%w[A B], [%w[wide_value x]])
    assert_includes @cli.lines[1], "wide_value"
    assert_includes @cli.lines[1], "x"
  end

  # ── newline ────────────────────────────────────────

  def test_newline_outputs_blank_line
    @cli.newline
    assert_equal 1, @cli.lines.size
    assert_equal "", @cli.lines[0]
  end
end
