defmodule Plausible.FinchSupervisor do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      use Supervisor

      @finch Keyword.fetch!(opts, :finch)

      def start_link(init_arg) do
        Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
      end

      def init(_init_arg) do
        children = [{Finch, name: @finch}]

        Supervisor.init(children, strategy: :one_for_one)
      end
    end
  end
end
