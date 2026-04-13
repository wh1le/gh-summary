module GhSummary
  class Runner
    include Colors

    RELEVANT_EVENTS = %w[IssuesEvent PullRequestEvent ReleaseEvent ForkEvent WatchEvent].freeze

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
      show_recent_activity unless @short_mode
      @cli.divider
      @cli.newline
    end

    private

    def repository_name(item)
      item.dig("repository", "nameWithOwner") || item.dig("repository", "name") || "?"
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
      if notifications.any?
        grouped_notifications = notifications.group_by { |notification| notification.dig("repository", "full_name") || "unknown" }
        grouped_notifications.each do |repository, notification_items|
          @cli.group("#{repository} (#{notification_items.size}):")
          notification_items.first(5).each do |notification|
            subject_type   = notification.dig("subject", "type") || "?"
            subject_title  = notification.dig("subject", "title") || "?"
            reason         = notification["reason"] || "?"
            @cli.sub_item("[#{subject_type}] #{subject_title} (#{reason})")
          end
        end
        @cli.count(notifications.size, "total unread")
      else
        @cli.success("All caught up!")
      end
    end

    def show_recent_activity
      @cli.header(CYAN, "Recent activity (your repos)")
      all_events = @github.events(per_page: 20)
      relevant_events = all_events.select { |event| RELEVANT_EVENTS.include?(event["type"]) }.first(10)
      if relevant_events.any?
        rows = relevant_events.map do |event|
          [event.dig("repo", "name") || "?",
           (event["type"] || "").sub("Event", ""),
           event.dig("payload", "action") || "—",
           (event["created_at"] || "").split("T").first]
        end
        @cli.table(%w[Repo Type Action Date], rows)
      else
        @cli.empty("No recent events")
      end
    end
  end
end
