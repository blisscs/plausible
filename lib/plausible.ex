defmodule Plausible do
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
