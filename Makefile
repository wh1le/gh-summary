.PHONY: start test publish

start:
	ruby bin/gh-summary

test:
	ruby -e 'Dir["test/test_*.rb"].each { |f| require_relative f }'

publish:
	gem build gh-summary.gemspec
	gem push gh-summary-$(shell ruby -r ./lib/gh_summary/version -e 'puts GhSummary::VERSION').gem
