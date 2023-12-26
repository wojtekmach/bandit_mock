defmodule BanditMock.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [{NimbleOwnership, name: BanditMock.Ownership}]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

defmodule BanditMock do
  def base_url(name) do
    callers =
      case Process.get(:"$callers") do
        nil -> [self()]
        pids when is_list(pids) -> pids
      end

    if info = NimbleOwnership.get_owner(BanditMock.Ownership, callers, name) do
      Map.fetch!(info.metadata, :base_url)
    else
      raise "no stub defined for #{inspect(name)} in process #{inspect(self())}"
    end
  end

  def stub(name, plug) do
    pid =
      ExUnit.Callbacks.start_supervised!(
        {Bandit, scheme: :http, port: 0, plug: {BanditMock.Plug, plug}, startup_log: false}
      )

    {:ok, {_, port}} = ThousandIsland.listener_info(pid)
    base_url = "http://localhost:#{port}"
    :ok = NimbleOwnership.allow(BanditMock.Ownership, self(), self(), name, %{base_url: base_url})
    :ok
  end
end

defmodule BanditMock.Plug do
  @moduledoc false
  @behaviour Plug

  @impl true
  def init(plug) when is_function(plug, 1), do: plug

  @impl true
  def call(conn, plug), do: plug.(conn)
end
