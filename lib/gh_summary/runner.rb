module GhSummary
  class Runner
    include Colors

    RELEVANT_EVENTS = %w[
      IssuesEvent
      PullRequestEvent
      ReleaseEvent
      ForkEvent
      WatchEvent
    ].freeze

    def initialize(short: false)
      @short_mode = short
      @cli = CLI.new
      @github = GitHub.new
    end

    def run
      @cli.banner
      show_section(
        YELLOW, "PRs awaiting your review",
        @github.search_prs("review-requested": "@me", state: "open"),
        empty: "None — you're clear!", empty_style: :success, count_label: "pending"
      )
      show_section(
        GREEN, "Your open PRs",
        @github.search_prs(author: "@me", state: "open"),
        empty: "No open PRs", count_label: "open"
      )
      show_section(
        RED, "Issues assigned to you",
        @github.search_issues(assignee: "@me", state: "open"),
        empty: "No assigned issues", count_label: "open"
      )
      show_notifications
      show_profile_stats unless @short_mode
      show_top_repos unless @short_mode
      show_recent_activity unless @short_mode
      @cli.divider
      @cli.newline
    end

    private

    def repository_name(item)
      item.dig("repository", "nameWithOwner") || item.dig("repository", "name")
    end

    def show_section(color, title, items, empty:, count_label:, empty_style: :empty)
      @cli.header(color, title)
      if items.any?
        items.each { |item| @cli.item(repository_name(item), item["title"], item["url"]) }
        @cli.count(items.size, count_label)
      else
        @cli.send(empty_style, empty)
      end
    end

    def show_notifications
      @cli.header(MAGENTA, "Unread notifications")
      notifications = @github.notifications
      return @cli.success("All caught up!") if notifications.empty?

      notifications.group_by { |n| n.dig("repository", "full_name") || "unknown" }.each do |repo, items|
        @cli.group("#{repo} (#{items.size}):")
        items.first(5).each do |n|
          type   = n.dig("subject", "type") || "?"
          title  = n.dig("subject", "title") || "?"
          reason = n["reason"] || "?"
          @cli.sub_item("[#{type}] #{title} (#{reason})")
        end
      end

      @cli.count(notifications.size, "total unread")
    end

    def show_profile_stats
      @cli.header(BLUE, "Profile stats")

      profile = @github.profile

      if profile.any?
        rows = [
          ["Followers", profile["followers"].to_s],
          ["Following", profile["following"].to_s],
          ["Public repos", profile["public_repos"].to_s]
        ]
        @cli.table(%w[Metric Count], rows)
      else
        @cli.empty("Could not load profile")
      end
    end

    def show_top_repos
      @cli.header(YELLOW, "Top repositories by stars")

      starred = @github.top_repos(sort: "stars", per_page: 10)
        .select { |r| (r["stargazers_count"] || 0) > 0 }
      return @cli.empty("No starred repositories") if starred.empty?

      rows = starred.map do |repo|
        [repo["full_name"] || repo["name"] || "?",
         "★ #{repo["stargazers_count"] || 0}",
         "⑂ #{repo["forks_count"] || 0}",
         "⚠ #{repo["open_issues_count"] || 0}"]
      end

      @cli.table(%w[Repository Stars Forks Issues], rows)
    end

    def show_recent_activity
      @cli.header(CYAN, "Recent activity (your repos)")
      relevant = @github.events(per_page: 20)
        .select { |e| RELEVANT_EVENTS.include?(e["type"]) }
        .first(10)

      return @cli.empty("No recent events") if relevant.empty?

      rows = relevant.map do |event|
        [event.dig("repo", "name") || "?",
         (event["type"] || "").sub("Event", ""),
         event.dig("payload", "action") || "—",
         (event["created_at"] || "").split("T").first]
      end

      @cli.table(%w[Repo Type Action Date], rows)
    end
  end
end
