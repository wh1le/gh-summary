require_relative "test_helper"

class TestRunner < Minitest::Test
  include GhSummary::Colors

  def test_repository_name_prefers_name_with_owner
    runner = build_runner
    item = {"repository" => {"nameWithOwner" => "owner/repo", "name" => "repo"}}
    assert_equal "owner/repo", runner.send(:repository_name, item)
  end

  def test_repository_name_falls_back_to_name
    runner = build_runner
    item = {"repository" => {"name" => "repo"}}
    assert_equal "repo", runner.send(:repository_name, item)
  end

  def test_repository_name_returns_question_mark_when_missing
    runner = build_runner
    assert_equal "?", runner.send(:repository_name, {})
  end

  def test_show_section_renders_items
    cli = TestCLIRecorder.new
    runner = build_runner(cli: cli)
    items = [
      {"repository" => {"nameWithOwner" => "o/r"}, "title" => "PR1", "url" => "http://1"},
      {"repository" => {"nameWithOwner" => "o/r"}, "title" => "PR2", "url" => "http://2"}
    ]
    runner.send(:show_section, GREEN, "Title", items, empty: "None", count_label: "open")
    output = cli.printed
    assert_includes output, "Title"
    assert_includes output, "PR1"
    assert_includes output, "PR2"
    assert_includes output, "(2 open)"
  end

  def test_show_section_renders_empty_state
    cli = TestCLIRecorder.new
    runner = build_runner(cli: cli)
    runner.send(:show_section, GREEN, "Title", [], empty: "Nothing", count_label: "open")
    output = cli.printed
    assert_includes output, "Nothing"
    refute_includes output, "(0 open)"
  end

  def test_show_section_renders_success_empty_style
    cli = TestCLIRecorder.new
    runner = build_runner(cli: cli)
    runner.send(:show_section, GREEN, "Title", [], empty: "Clear!", empty_style: :success, count_label: "x")
    output = cli.printed
    assert_includes output, GREEN
    assert_includes output, "Clear!"
  end

  def test_show_notifications_groups_by_repo
    cli = TestCLIRecorder.new
    github = FakeGitHub.new
    github.responses[:notifications] = [
      {"repository" => {"full_name" => "org/repo"}, "subject" => {"type" => "Issue", "title" => "Bug"}, "reason" => "mention"},
      {"repository" => {"full_name" => "org/repo"}, "subject" => {"type" => "PR", "title" => "Fix"}, "reason" => "review"}
    ]
    runner = build_runner(cli: cli, github: github)
    runner.send(:show_notifications)
    output = cli.printed
    assert_includes output, "org/repo (2):"
    assert_includes output, "[Issue] Bug (mention)"
    assert_includes output, "[PR] Fix (review)"
    assert_includes output, "(2 total unread)"
  end

  def test_show_notifications_empty
    cli = TestCLIRecorder.new
    runner = build_runner(cli: cli)
    runner.send(:show_notifications)
    output = cli.printed
    assert_includes output, "All caught up!"
  end

  def test_show_notifications_limits_to_5_per_group
    cli = TestCLIRecorder.new
    github = FakeGitHub.new
    github.responses[:notifications] = 7.times.map do |index|
      {"repository" => {"full_name" => "org/repo"}, "subject" => {"type" => "Issue", "title" => "Item #{index}"}, "reason" => "mention"}
    end
    runner = build_runner(cli: cli, github: github)
    runner.send(:show_notifications)
    output = cli.printed
    assert_includes output, "Item 4"
    refute_includes output, "Item 5"
  end

  def test_show_recent_activity_filters_relevant_events
    cli = TestCLIRecorder.new
    github = FakeGitHub.new
    github.responses[:events] = [
      {"type" => "PullRequestEvent", "repo" => {"name" => "org/repo"}, "payload" => {"action" => "opened"}, "created_at" => "2026-01-15T10:00:00Z"},
      {"type" => "PushEvent", "repo" => {"name" => "org/other"}, "payload" => {}, "created_at" => "2026-01-15T10:00:00Z"}
    ]
    runner = build_runner(cli: cli, github: github)
    runner.send(:show_recent_activity)
    output = cli.printed
    assert_includes output, "org/repo"
    assert_includes output, "PullRequest"
    refute_includes output, "org/other"
  end

  def test_show_recent_activity_limits_to_10
    cli = TestCLIRecorder.new
    github = FakeGitHub.new
    github.responses[:events] = 15.times.map do |index|
      {"type" => "IssuesEvent", "repo" => {"name" => "org/r#{index}"}, "payload" => {"action" => "opened"}, "created_at" => "2026-01-15T00:00:00Z"}
    end
    runner = build_runner(cli: cli, github: github)
    runner.send(:show_recent_activity)
    output = cli.printed
    assert_includes output, "org/r9"
    refute_includes output, "org/r10"
  end

  def test_show_recent_activity_empty
    cli = TestCLIRecorder.new
    runner = build_runner(cli: cli)
    runner.send(:show_recent_activity)
    output = cli.printed
    assert_includes output, "No recent events"
  end

  def test_run_short_mode_skips_recent_activity
    cli = TestCLIRecorder.new
    runner = build_runner(cli: cli, short: true)
    runner.run
    output = cli.printed
    refute_includes output, "Recent activity"
  end

  def test_run_full_mode_includes_recent_activity
    cli = TestCLIRecorder.new
    runner = build_runner(cli: cli, short: false)
    runner.run
    output = cli.printed
    assert_includes output, "Recent activity"
  end

  def test_run_includes_all_sections
    cli = TestCLIRecorder.new
    runner = build_runner(cli: cli)
    runner.run
    output = cli.printed
    assert_includes output, "GitHub Summary"
    assert_includes output, "PRs awaiting your review"
    assert_includes output, "Your open PRs"
    assert_includes output, "Issues assigned to you"
    assert_includes output, "Unread notifications"
  end

  private

  def build_runner(cli: TestCLIRecorder.new, github: FakeGitHub.new, short: false)
    runner = GhSummary::Runner.allocate
    runner.instance_variable_set(:@short_mode, short)
    runner.instance_variable_set(:@cli, cli)
    runner.instance_variable_set(:@github, github)
    runner
  end
end
