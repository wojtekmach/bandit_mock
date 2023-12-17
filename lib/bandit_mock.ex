defmodule BanditMock do
  def defmock(name), do: Mox.defmock(mock_name(name), for: BanditMock.API)

  def base_url(name) do
    ensure_mock!(name).base_url()
  rescue
    Mox.UnexpectedCallError ->
      raise "no stub defined for mock #{inspect(name)} in process #{inspect(self())}"
  end

  def stub(name, plug) do
    pid =
      ExUnit.Callbacks.start_supervised!(
        {Bandit, scheme: :http, port: 0, plug: {BanditMock.Plug, plug}, startup_log: false}
      )

    {:ok, {_, port}} = ThousandIsland.listener_info(pid)
    base_url = "http://localhost:#{port}"
    Mox.stub(ensure_mock!(name), :base_url, fn -> base_url end)
    :ok
  end

  defp ensure_mock!(name) do
    case Code.ensure_compiled(mock_name(name)) do
      {:module, mod} -> mod
      {:error, _} -> raise "unknown mock #{inspect(name)}"
    end
  end

  defp mock_name(name), do: Module.concat(BanditMock.Mocks, name)
end

defmodule BanditMock.Plug do
  @moduledoc false

  @behaviour Plug

  @impl true
  def init(plug) when is_function(plug, 1), do: plug

  @impl true
  def call(conn, plug), do: plug.(conn)
end

defmodule BanditMock.API do
  @moduledoc false

  @callback base_url() :: String.t()
end
