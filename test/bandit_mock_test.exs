defmodule BanditMockTest do
  use ExUnit.Case, async: true

  test "it works", %{test: test} do
    assert_raise RuntimeError, "unknown mock #{inspect(test)}", fn ->
      BanditMock.base_url(test)
    end

    BanditMock.defmock(test)

    assert_raise RuntimeError,
                 "no stub defined for mock #{inspect(test)} in process #{inspect(self())}",
                 fn ->
                   BanditMock.base_url(test)
                 end

    BanditMock.stub(test, fn conn ->
      Plug.Conn.send_resp(conn, 200, "hi")
    end)

    assert Req.get!(BanditMock.base_url(test)).body == "hi"

    Task.async(fn ->
      assert Req.get!(BanditMock.base_url(test)).body == "hi"
    end)
  end
end

[_, "elixir\n" <> code, _] = File.read!("README.md") |> String.split("```")
{:ok, quoted} = Code.string_to_quoted(code)

quoted
|> Macro.prewalk(fn
  {{:., _, [{:__aliases__, _, [:Mix]}, :install]}, _, _} ->
    :ok

  other ->
    other
end)
|> Code.eval_quoted()
