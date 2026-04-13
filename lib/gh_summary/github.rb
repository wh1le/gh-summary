require "json"
require "open3"

module GhSummary
  class GitHub
    def initialize
      unless system("gh", "auth", "status", out: File::NULL, err: File::NULL)
        raise AuthError, "gh is not authenticated. Run 'gh auth login' first."
      end
    end

    def search_prs(**options)
      flags = options.map { |key, value| "--#{key}=#{value}" }
      fetch_json("search", "prs", *flags, "--json", "title,repository,url,updatedAt", "--limit", "15")
    end

    def search_issues(**options)
      flags = options.map { |key, value| "--#{key}=#{value}" }
      fetch_json("search", "issues", *flags, "--json", "title,repository,url", "--limit", "15")
    end

    def notifications
      fetch_json("api", "notifications")
    end

    def events(per_page: 20)
      fetch_json("api", "events", "-f", "per_page=#{per_page}")
    end

    private

    def execute(*arguments)
      output, _stderr, status = Open3.capture3("gh", *arguments)
      status.success? ? output : nil
    end

    def fetch_json(*arguments)
      output = execute(*arguments)
      return [] unless output
      parsed = JSON.parse(output)
      parsed.is_a?(Array) ? parsed : [parsed]
    rescue JSON::ParserError
      []
    end
  end
end
