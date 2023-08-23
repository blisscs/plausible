defmodule Plausible do
  @moduledoc """
  ## Status

  Currently the project is under development. All contributions are welcome.

  ## V0.1.0 Roadmap

  1. Add `__using__/1` macro to `Plausible` so to allow usages like

  ```elixir
    defmodule MyApp.Plausible do
      use Plausible, finch: MyApp.Finch
    end
  ```

  with this you can use `Plausible.create_event(opts)` instead of `Plausible.create_event/3`

  2. Add documentation for `Plausible.FinchSupervisor` and the usage so the host app can create a finch process and the supervision
  for the finch process on the app instead of under library supervision, which will help when in umbrella app case, where
  two or more apps in the umbrella can have this library as dependency, but the finch processes will be spawn and supervised seperately
  on host apps

  """

  @doc """
  Create Plausible Event

  Currently only returns `:ok`

  ## Examples

      iex> create_event("https://plausible.io/api/event", MyApp.Finch, user_agent: user_agent, x_forward_for: x_forwarded_for, url: url, domain: domain)
      :ok
  """
  def create_event(endpoint \\ "https://plausible.io/api/event", finch_process, opts) do
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
        endpoint,
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
