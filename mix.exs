defmodule BanditMock.MixProject do
  use Mix.Project

  def project do
    [
      app: :bandit_mock,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {BanditMock.Application, []}
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.0"},
      {:nimble_ownership, "~> 0.1.0"},
      {:req, "~> 0.4", only: :test}
    ]
  end
end
