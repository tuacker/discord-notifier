defmodule DiscordNotifier do
  @moduledoc """
  Sends messages to a discord webhook honoring the rate-limit.
  """
  use GenServer, restart: :permanent

  # Client API

  def start_link(state) when is_list(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def send(message) when is_binary(message) do
    GenServer.cast(__MODULE__, {:send, message})
  end

  # Server impl

  @impl true
  def init(_opts) do
    webhook = Application.get_env(:discord_notifier, :webhook, "") <> "?wait=true"
    {:ok, {:queue.new(), webhook, false}}
  end

  @impl true
  def handle_info(:send, state) do
    state = process_messages(state)
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:send, new_message}, {queue, webhook, true}) do
    # Currently rate-limited, only add the message to the queue.
    {:noreply, {:queue.in(new_message, queue), webhook, true}}
  end

  def handle_cast({:send, new_message}, {queue, webhook, false}) do
    queue = :queue.in(new_message, queue)
    state = process_messages({queue, webhook, false})
    {:noreply, state}
  end

  defp process_messages({{[], []} = queue, webhook, true}), do: {queue, webhook, false}
  defp process_messages({{[], []}, _, false} = state), do: state

  defp process_messages({queue, webhook, _rate_limited} = state) do
    {{:value, message}, queue} = :queue.out(queue)

    case send_message(message, webhook) do
      {:ok, :processed} -> process_messages({queue, webhook, false})
      {:error, error} -> wait(error, state)
    end
  end

  defp wait({:rate_limited, wait_for}, {queue, webhook, _}) do
    # Got rate limited by discord, wait for provided duration to resume sending
    Process.send_after(self(), :send, wait_for)
    {queue, webhook, true}
  end

  defp wait(_error, state) do
    # Error occurred trying to send message, try again in a second
    Process.send_after(self(), :send, 1_000)
    state
  end

  if Application.get_env(:discord_notifier, :testing, false) do
    defp send_message(message, _webhook) when is_binary(message) do
      require Logger
      Logger.debug("[DiscordNotifier] #{inspect(message)}")
      {:ok, :processed}
    end
  else
    defp send_message(message, webhook) when is_binary(message) do
      headers = ["Content-Type": "application/json"]
      payload = %{content: message} |> Jason.encode!()

      case :hackney.post(webhook, headers, payload, [:with_body]) do
        {:ok, 200, _, _} -> {:ok, :processed}
        {:ok, 429, _, body} -> {:error, {:rate_limited, Jason.decode!(body)["retry_after"]}}
        _ -> {:error, :unknown}
      end
    end
  end
end
