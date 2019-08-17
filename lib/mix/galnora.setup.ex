defmodule Mix.Tasks.Galnora.Setup do
  use Mix.Task

  @shortdoc "Creates an Mnesia DB on disk for Galnora"

  @moduledoc """
  Creates an Mnesia DB on disk for Galnora

    ###

    config :mnesia, dir: 'mnesia/\#{Mix.env}/\#{node()}'
    # Notice the single quotes

    ###
  """

  @doc false
  def run(_) do
    Galnora.DB.Mnesia.setup!
  end
end
