defmodule Plausible.Client do
  @moduledoc """
  `Plausible.Client` provides a wrapper to internal for calling to functions defined on `Plausible` module.

  ## Usage

  1. Create your client module.

  ```elixir
  defmodule MyApp.Plausible do
    use Plausible.Client, finch_pool_name: MyApp.Finch
  end
  ```

  Optional options include `plausbile_host_url` where the base_url of self hosted plausible can be passed in.

  2. Once module is defined can use `create_event/1` as below to send event to Plausible host.

  ```elixir
  MyApp.Plausible.create_event(user_agent: user_agent, x_forwarded_for: x_forwarded_for, url: url, domain: domain)

  # returns `:ok` or `{:error, status_code, body}` or {:error, `Exception.t()`}
  ```
  """
  defmacro __using__(opts) do
    finch_pool_name = Keyword.fetch!(opts, :finch_pool_name)
    plausible_host_url = Keyword.get(opts, :plausible_host_url, "https://plausible.io")

    quote do
      def create_event(opts) do
        Plausible.create_event(unquote(plausible_host_url), unquote(finch_pool_name), opts)
      end

      def create_event!(opts) do
        Plausible.create_event!(unquote(plausible_host_url), unquote(finch_pool_name), opts)
      end
    end
  end
end
