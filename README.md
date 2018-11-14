# DiscordNotifier

A notifier to send messages to a discord webhook with retry mechanism.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `discord_notifier` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:discord_notifier, "~> 0.1.0"}
  ]
end
```

# Config

```elixir
config :discord_notifier,
  webhook: "https://discordapp.com/api/webhooks/{id}/{token}"
```

And for testing:

```elixir
config :discord_notifier, testing: true
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/discord_notifier](https://hexdocs.pm/discord_notifier).

