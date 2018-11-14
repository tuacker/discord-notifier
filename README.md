# DiscordNotifier

A notifier to send messages to a discord webhook with retry mechanism.

## Installation

Currently not published to hex. Add dependency from this repository instead.

```elixir
def deps do
  [
    {:discord_notifier, "~> 1.0", git: "https://gitlab.com/tuacker/discord-notifier.git"}
  ]
end
```

# Config

1. In the Discord client, go to the server and open the settings of a text channel.
2. Go to Webhooks and create a new hook
3. Copy the entire webhook url into the config as shown below

```elixir
config :discord_notifier,
  webhook: "https://discordapp.com/api/webhooks/{your_channel_id}/{your_channel_token}"
```

For testing set `testing` to `true` and the notifier will output messages to the `Logger`.

```elixir
config :discord_notifier, testing: true
```
