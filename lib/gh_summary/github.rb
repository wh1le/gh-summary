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
      search("prs", "title,repository,url,updatedAt", **options)
    end

    def search_issues(**options)
      search("issues", "title,repository,url", **options)
    end

    def notifications
      api("notifications")
    end

    def events(per_page: 20)
      api("events", per_page: per_page)
    end

    def profile
      result = api("user")
      result.first || {}
    end

    def top_repos(sort: "stars", per_page: 10)
      api("user/repos", sort: sort, per_page: per_page, direction: "desc")
    end

    private

    def search(resource, fields, limit: 15, **options)
      flags = options.map { |key, value| "--#{key}=#{value}" }
      fetch_json(
        "search",
        resource,
        *flags,
        "--json",
        fields,
        "--limit",
        limit.to_s
      )
    end

    def api(endpoint, **params)
      flags = params.flat_map { |key, value| ["-f", "#{key}=#{value}"] }
      fetch_json("api", endpoint, *flags)
    end

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
