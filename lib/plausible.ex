defmodule Plausible do
  @moduledoc """
  `Plausible` is a library to push analytics event to [Plausible Analytics]("https://plausible.io").
  The library provides two working mode to push events.

  ## Installation

  1. Add `:plausible` to your project `mix.exs` dependencies

  ```elixir
    def deps() do
      [ #other dependendencies excluded here
        {:plausible, "~> 0.1.0"}
      ]
    end
  ```

  2. Initialize `finch` process in your app supervision tree.

  ```elixir
    def start(_type, _arg) do
      children = [{Finch, name: MyApp.Finch}]
    end
  ```

  ## Usages

  The library provides two working modes as listed below

  1. Use `Plausible.Client` as the wrapper to `Plausible` module so you can pass in less parameters.
  2. Or use `Plausible` directly that accepts a finch process name and keyword `opts` parameter directly to send event to Plausible Analytics Host. 

  The document can be found on each `Plausible` and `Plausible.Client`

  ## Contributions

  All contributions are welcome. Please visit https://github.com/blisscs/plausible and create issue or pull request there.
  """

  @doc """
  Create Plausible Event

  Currently only returns `:ok`

  ## Examples

      iex> create_event(MyApp.Finch, user_agent: user_agent, x_forwarded_for: x_forwarded_for, url: url, domain: domain)
      :ok
  """
  def create_event(endpoint \\ "https://plausible.io", finch_process, opts) do
    path = "/api/event"

    user_agent =
      opts[:user_agent] ||
        raise """
        user_agent not defined
        """

    x_forwarded_for =
      opts[:x_forwarded_for] ||
        raise """
        x_forwarded_for not defined
        """

    domain =
      opts[:domain] ||
        raise """
        domain not defined
        """

    url =
      opts[:url] ||
        raise """
        url not defined
        """

    referrer = opts[:referrer]

    event_name = opts[:event_name] || "pageview"

    body = %{name: event_name, url: url, referrer: referrer, domain: domain} |> Jason.encode!()

    # TODO handle custom properties

    %Finch.Response{status: 202} =
      Finch.build(
        :post,
        "#{endpoint}#{path}",
        [
          {"User-Agent", user_agent},
          {"X-Forwarded-For", x_forwarded_for},
          {"Content-Type", "application/json"}
        ],
        body
      )
      |> Finch.request!(finch_process)

    :ok
  end
end
