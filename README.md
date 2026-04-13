# gh-summary

GitHub activity digest in your terminal. Shows open PRs, review requests, assigned issues, unread notifications, and recent activity.

No gems. Just Ruby and the `gh` CLI.

## Requirements

- Ruby (any modern version)
- [GitHub CLI](https://cli.github.com/) (`gh`), authenticated

## Usage

```
make start
```

Short mode (skip recent activity):

```
ruby bin/gh-summary --short
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
