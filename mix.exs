defmodule TwitterBusinessAnalysis.Mixfile do
  use Mix.Project

  def project do
    [app: :twitter_business_analysis,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [
      extra_applications: [
        :exredis,
        :httpoison,
        :logger,
        :simple_bayes,
        :stemmer
      ]
    ]
  end

  defp deps do
    [
      {:csv, "~> 1.4.2"},
      {:exredis, "~> 0.2.4"},
      {:httpoison, "~> 0.10.0"},
      {:poison, "~> 3.0"},
      {:simple_bayes, "~> 0.11.0"},
      {:stemmer,      "~> 1.0"}
    ]
  end
end
