defmodule PlausbileTestClientTest do
  use ExUnit.Case, async: true

  alias Plug.Conn

  test "send event to bypass host" do
    bypass = Bypass.open(port: 10000)

    Bypass.expect(bypass, "POST", "/api/event", fn conn ->
      assert "application/json" in Conn.get_req_header(conn, "content-type")
      assert "useragent" in Conn.get_req_header(conn, "user-agent")
      assert "x_forwarded_for" in Conn.get_req_header(conn, "x-forwarded-for")

      Conn.send_resp(conn, 202, "")
    end)

    assert :ok ==
             PlausbileTestClient.create_event(
               user_agent: "useragent",
               x_forwarded_for: "x_forwarded_for",
               domain: "domain",
               url: "url"
             )
  end
end
