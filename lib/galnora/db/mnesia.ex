defmodule Galnora.DB.Mnesia do
  @moduledoc false

  alias Galnora.DB.{Job, Sentence}

  @doc """
  Setup DB
  """
  def setup!(nodes \\ [node()]) do
    # Create the DB directory (if custom path given)
    if path = Application.get_env(:mnesia, :dir) do
      :ok = File.mkdir_p!(path)
    end

    # Create the Schema
    Memento.stop
    Memento.Schema.create(nodes)
    Memento.start

    # Create the DB with Disk Copies
    Memento.Table.create!(Job, disc_copies: nodes)
    Memento.Table.create!(Sentence, disc_copies: nodes)
  end  
end
