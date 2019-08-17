defmodule Galnora.MixProject do
  use Mix.Project

  @description """
  Translation processing with Elixir
  """

  def project do
    [
      app: :galnora,
      version: "0.0.1",
      elixir: "~> 1.9",
      name: "Galnora",
      description: @description,
      source_url: "https://github.com/kortirso/galnora",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Anton Bogdanov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kortirso/galnora"}
    ]
  end
end
