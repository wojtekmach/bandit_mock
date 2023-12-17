# BanditMock

```elixir
Mix.install([
  {:req, "~> 0.4"},
  {:bandit_mock, github: "wojtekmach/bandit_mock"}
])

Application.put_env(:github, :mock, true)

defmodule GitHub do
  if Application.compile_env(:github, :mock, false) do
    @mock __MODULE__.Mock

    BanditMock.defmock(@mock)

    def stub(fun), do: BanditMock.stub(@mock, fun)

    def api_token, do: "dummy"

    def base_url, do: BanditMock.base_url(@mock)
  else
    def api_token, do: System.fetch_env!("GITHUB_API_KEY")

    def base_url, do: "https://api.github.com"
  end

  def new(options \\ []) do
    Req.new(
      base_url: base_url(),
      auth: {:bearer, api_token()},
      headers: [
        x_github_api_version: "2022-11-28"
      ],
      http_errors: :raise
    )
    |> Req.update(options)
  end

  def request!(options) do
    Req.request!(new(), options)
  end
end

ExUnit.start()

defmodule GitHubTest do
  use ExUnit.Case, async: true

  test "it works" do
    GitHub.stub(fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, Jason.encode!(%{login: "wojtekmach"}))
    end)

    assert GitHub.request!(url: "/user").body["login"] == "wojtekmach"

    # works from child processes (of the test process) too
    Task.async(fn ->
      assert GitHub.request!(url: "/user").body["login"] == "wojtekmach"
    end)
    |> Task.await()
  end
end
```

## License

Copyright 2023 Wojtek Mach

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
