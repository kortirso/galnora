defmodule Galnora.Supervisor do
  @moduledoc false

  import Supervisor.Spec

  @doc """
  Starts the Supervision Tree
  """
  def start(params \\ []) do
    children = [
      worker(Galnora.Server, params, name: Galnora.Server)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
