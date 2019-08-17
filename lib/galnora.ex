defmodule Galnora do
  @moduledoc false

  use Application

  @doc """
  Starts the Galnora Application (and its Supervision Tree)
  """
  def start(_type, _args) do
    Galnora.Supervisor.start
  end
end
