# State Machine for Crystal

Minimal State Machine, inspired by [micromachine](https://github.com/soveran/micromachine)

## Installation

Add it to `Projectfile`

```crystal
deps do
  github "luislavena/crystal-state_machine"
end
```

## Usage

```crystal
require "state_machine"

machine = StateMachine.new(:pending)
machine.when(:confirm, { pending: :confirmed })
machine.when(:ignore,  { pending: :ignored })
machine.when(:reset,   { confirmed: :pending, ignored: :pending })

machine.on(:confirmed) do
  puts "Confirmed"
end

machine.trigger(:confirm)
machine.state              # => :confirmed

machine.trigger?(:ignore)  # => false
```

## Development

TODO: Write instructions for development

## Contributing

1. Fork it ( https://github.com/luislavena/crystal-state_machine/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- luislavena(https://github.com/luislavena) Luis Lavena - creator, maintainer
