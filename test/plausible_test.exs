defmodule PlausibleTest do
  use ExUnit.Case, async: true

  alias Plug.Conn
  alias Plug.Parsers

  test "send event to bypass" do
    bypass = Bypass.open()

    Bypass.expect(bypass, "POST", "/api/event", fn conn ->
      assert "application/json" in Conn.get_req_header(conn, "content-type")
      assert "useragent" in Conn.get_req_header(conn, "user-agent")
      assert "x_forwarded_for" in Conn.get_req_header(conn, "x-forwarded-for")

      conn = Parsers.call(conn, conn_parser_opts())

      assert %{
               "domain" => "domain",
               "name" => "pageview",
               "referrer" => nil,
               "url" => "url"
             } == conn.params

      Conn.send_resp(conn, 202, "")
    end)

    assert :ok ==
             Plausible.create_event("http://localhost:#{bypass.port}/api/event", Plausible.Finch,
               user_agent: "useragent",
               x_forwarded_for: "x_forwarded_for",
               domain: "domain",
               url: "url"
             )
  end

  defp conn_parser_opts() do
    [
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Jason
    ]
    |> Plug.Parsers.init()
  end
end
