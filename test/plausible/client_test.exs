defmodule PlausbileClientTest do
  # can not use async: true here is we are using single http server
  # to receive the request in single http port
  use ExUnit.Case

  defmodule Client do
    use Plausible.Client,
      finch_pool_name: Plausible.Finch,
      plausible_host_url: "http://localhost:10000"
  end

  alias Plug.Conn

  setup do
    bypass = Bypass.open(port: 10_000)

    Bypass.up(bypass)

    {:ok, bypass: bypass}
  end

  test "create_event successfully", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/api/event", fn conn ->
      assert "application/json" in Conn.get_req_header(conn, "content-type")
      assert "useragent" in Conn.get_req_header(conn, "user-agent")
      assert "x_forwarded_for" in Conn.get_req_header(conn, "x-forwarded-for")

      Conn.send_resp(conn, 202, "")
    end)

    assert :ok ==
             Client.create_event(
               user_agent: "useragent",
               x_forwarded_for: "x_forwarded_for",
               domain: "domain",
               url: "url"
             )
  end

  test "create_event failure", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/api/event", fn conn ->
      Conn.send_resp(conn, 404, "")
    end)

    assert {:error, 404, ""} ==
             Client.create_event(
               user_agent: "useragent",
               x_forwarded_for: "x_forwarded_for",
               domain: "domain",
               url: "url"
             )
  end

  test "create_event! successfully", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/api/event", fn conn ->
      Conn.send_resp(conn, 202, "")
    end)

    assert :ok ==
             Client.create_event!(
               user_agent: "useragent",
               x_forwarded_for: "x_forwarded_for",
               domain: "domain",
               url: "url"
             )
  end

  test "create_event! raise exception when non 202 response returns", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/api/event", fn conn ->
      Conn.send_resp(conn, 404, "")
    end)

    assert_raise Plausible.Exception, "status_code: 404, error: ", fn ->
      Client.create_event!(
        user_agent: "useragent",
        x_forwarded_for: "x_forwarded_for",
        domain: "domain",
        url: "url"
      )
    end
  end

  test "create_event! raise exception when errors", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/api/event", fn conn ->
      # cause the client to timeout
      Bypass.pass(bypass)
      Bypass.down(bypass)

      conn
    end)

    assert_raise Plausible.Exception, "closed", fn ->
      Client.create_event!(
        user_agent: "useragent",
        x_forwarded_for: "x_forwarded_for",
        domain: "domain",
        url: "url"
      )
    end
  end
end
