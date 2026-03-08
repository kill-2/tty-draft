# TTY::Draft

Just like `TTY::Prompt#multiline` but let you move cursor around to edit before submission.

## Installation

```bash
bundle add tty-draft
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install tty-draft
```

## Usage

```ruby
require 'tty-draft'

draft = TTY::Draft.new(
  prompt: ->(n){n==0 ? "\033[32m> \033[0m" : '  '}
)

loop do
  draft.gets
  puts "I see"
end
```

- `enter`: new line
- arrow keys: move cursor around and retrieve history
- `ctrl-d`/`ctrl-z`: submit

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
