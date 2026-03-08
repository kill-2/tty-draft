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

loop do
  puts TTY::Draft.gets
  puts "I see"
end
```

- `enter`: submit
- `shift+enter`: new line
- arrow keys: move cursor around

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
