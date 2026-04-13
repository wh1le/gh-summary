require_relative "lib/gh_summary/version"

Gem::Specification.new do |spec|
  spec.name          = "gh-summary"
  spec.version       = GhSummary::VERSION
  spec.authors       = ["Nikita Miloserdov"]
  spec.email         = ["nmiloserdov@proton.me"]

  spec.summary       = "GitHub activity digest in your terminal"
  spec.description   = "Shows open PRs, review requests, assigned issues, unread notifications, and recent activity. Wraps the gh CLI. No dependencies."
  spec.homepage      = "https://github.com/wh1le/gh-summary"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.files         = Dir["lib/**/*.rb", "bin/*", "README.md", "LICENSE"]
  spec.bindir        = "bin"
  spec.executables   = ["gh-summary"]

  spec.metadata["homepage_uri"]    = "https://rubygems.org/gems/gh-summary"
  spec.metadata["source_code_uri"] = "https://github.com/wh1le/gh-summary"
end
