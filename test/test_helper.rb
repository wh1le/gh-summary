require "minitest/autorun"
require "json"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "gh_summary"

# Test-only CLI subclass that captures output in memory
class TestCLIRecorder < GhSummary::CLI
  attr_reader :lines, :error_lines

  def initialize
    super
    @lines = []
    @error_lines = []
  end

  def printed
    @lines.join("\n") + "\n"
  end

  private

  def output(text = "")
    @lines << text
  end

  # Override error to avoid $stderr
  public

  def error(text)
    @error_lines << text
  end
end

# Test-only GitHub subclass that never shells out
class FakeGitHub < GhSummary::GitHub
  attr_accessor :responses

  def initialize
    @responses = {}
  end

  def search_prs(**options)
    @responses[:search_prs] || []
  end

  def search_issues(**options)
    @responses[:search_issues] || []
  end

  def notifications
    @responses[:notifications] || []
  end

  def events(per_page: 20)
    @responses[:events] || []
  end
end
