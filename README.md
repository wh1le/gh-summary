# gh-summary

[![Gem Version](https://badge.fury.io/rb/gh-summary.svg)](https://rubygems.org/gems/gh-summary)

Your GitHub day at a glance — PRs, reviews, issues, notifications — all in one terminal command.

Zero dependencies. Ruby + `gh` CLI.

## Install

```
gem install gh-summary
```

## Requirements

- Ruby >= 3.0
- [gh](https://cli.github.com/), authenticated

## Usage

```
gh-summary
gh-summary --short
```

`--short` skips the recent activity section.

## Output

```
  GitHub Summary  2026-04-13 14:54
────────────────────────────────────────────────────────────
  PRs awaiting your review
    torvalds/linux — Fix memory leak in page allocator
      https://github.com/torvalds/linux/pull/842
    rails/rails — ActiveRecord: add async batch find
      https://github.com/rails/rails/pull/51203
  (2 pending)
────────────────────────────────────────────────────────────
  Your open PRs
    matz/ruby — Optimize frozen string dedup in parser
      https://github.com/matz/ruby/pull/9104
    sinatra/sinatra — Add streaming response helpers
      https://github.com/sinatra/sinatra/pull/1877
    rack/rack — Fix multipart boundary parsing edge case
      https://github.com/rack/rack/pull/2190
  (3 open)
────────────────────────────────────────────────────────────
  Issues assigned to you
    homebrew/brew — Formula audit fails on Apple Silicon
      https://github.com/homebrew/brew/issues/17450
  (1 open)
────────────────────────────────────────────────────────────
  Unread notifications
    rails/rails (3):
      [Issue] ActiveStorage mirror sync regression (mention)
      [PullRequest] Fix connection pool exhaustion (review_requested)
      [Release] v8.1.0 (subscribed)
    ruby/ruby (1):
      [Issue] YJIT segfault on ARM64 (assign)
  (4 total unread)
────────────────────────────────────────────────────────────
  Recent activity (your repos)
  Repo                            Type             Action      Date
  matz/ruby                       PullRequest      opened      2026-04-12
  sinatra/sinatra                 Issues           closed      2026-04-11
  rack/rack                       PullRequest      merged      2026-04-10
────────────────────────────────────────────────────────────
```

## Tests

```
make test
```

## Structure

```
.
├── bin
│   └── gh-summary
├── lib
│   ├── gh_summary
│   │   ├── auth_error.rb
│   │   ├── cli.rb
│   │   ├── colors.rb
│   │   ├── github.rb
│   │   └── runner.rb
│   └── gh_summary.rb
├── Makefile
├── README.md
└── test
    ├── test_auth_error.rb
    ├── test_cli.rb
    ├── test_colors.rb
    ├── test_github.rb
    ├── test_helper.rb
    └── test_runner.rb
```
