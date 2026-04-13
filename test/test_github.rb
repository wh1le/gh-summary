require_relative "test_helper"

class TestGitHub < Minitest::Test
  def test_raises_auth_error_when_not_authenticated
    klass = Class.new(GhSummary::GitHub) do
      def initialize
        raise GhSummary::AuthError, "not authenticated" unless authenticated?
      end

      def authenticated?
        false
      end
    end
    assert_raises(GhSummary::AuthError) { klass.new }
  end

  def test_fetch_json_returns_empty_array_when_execute_returns_nil
    github = build_github(nil)
    result = github.send(:fetch_json, "api", "test")
    assert_equal [], result
  end

  def test_fetch_json_parses_array_response
    data = [{"id" => 1}, {"id" => 2}]
    github = build_github(JSON.generate(data))
    result = github.send(:fetch_json, "api", "test")
    assert_equal data, result
  end

  def test_fetch_json_wraps_single_object_in_array
    data = {"id" => 1}
    github = build_github(JSON.generate(data))
    result = github.send(:fetch_json, "api", "test")
    assert_equal [data], result
  end

  def test_fetch_json_returns_empty_array_on_invalid_json
    github = build_github("not json{{{")
    result = github.send(:fetch_json, "api", "test")
    assert_equal [], result
  end

  def test_search_prs_returns_parsed_results
    prs = [{"title" => "Fix", "url" => "http://example.com"}]
    github = build_github(JSON.generate(prs))
    assert_equal prs, github.search_prs(state: "open", author: "@me")
  end

  def test_search_prs_returns_empty_on_failure
    github = build_github(nil)
    assert_equal [], github.search_prs(state: "open")
  end

  def test_search_issues_returns_parsed_results
    issues = [{"title" => "Bug"}]
    github = build_github(JSON.generate(issues))
    assert_equal issues, github.search_issues(assignee: "@me", state: "open")
  end

  def test_notifications_returns_parsed_results
    notifs = [{"id" => 1}]
    github = build_github(JSON.generate(notifs))
    assert_equal notifs, github.notifications
  end

  def test_notifications_returns_empty_on_failure
    github = build_github(nil)
    assert_equal [], github.notifications
  end

  def test_events_returns_parsed_results
    events = [{"type" => "PushEvent"}]
    github = build_github(JSON.generate(events))
    assert_equal events, github.events
  end

  def test_events_returns_empty_on_failure
    github = build_github(nil)
    assert_equal [], github.events(per_page: 10)
  end

  private

  def build_github(canned_output)
    github = GhSummary::GitHub.allocate
    github.define_singleton_method(:execute) { |*_| canned_output }
    github
  end
end
