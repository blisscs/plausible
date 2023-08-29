defmodule PlausbileTestClient do
  use Plausible.Client,
    finch_pool_name: Plausible.Finch,
    plausible_host_url: "http://localhost:10000"
end
