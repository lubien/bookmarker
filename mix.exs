defmodule Bookmarker.Mixfile do
  use Mix.Project

  def project do
    [app: :bookmarker,
     escript: escript_config,
     default_task: "escript.build",
     version: "1.0.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:poison, "~> 3.0"}]
  end

  defp escript_config do
    [ main_module: Bookmarker.CLI ]
  end
end
