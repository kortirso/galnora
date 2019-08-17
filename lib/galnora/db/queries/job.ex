defmodule Galnora.DB.Queries.Job do
  @moduledoc false

  alias Galnora.DB.Job
  alias Memento.Query

  @doc """
  Read all jobs
  """
  def read_all do
    Memento.transaction! fn ->
      Query.all(Job)
    end
  end

  @doc """
  Create new job
  """
  def create(%{type: type, from: from, to: to, keys: keys}) do
    Memento.transaction! fn ->
      Query.write(%Job{status: :active, type: type, from: from, to: to, keys: keys})
    end
  end

  @doc """
  Update job
  """
  def update(%Job{} = job) do
    Memento.transaction! fn ->
      Query.write(job)
    end
  end

  @doc """
  Get list of completed jobs
  """
  def completed_jobs do
    run_select_query(
      {:==, :status, :completed}
    )
  end

  @doc """
  Get list of active jobs
  """
  def active_jobs do
    run_select_query(
      {:==, :status, :active}
    )
  end

  defp run_select_query(pattern) do
    Memento.transaction! fn ->
      Query.select(Job, pattern)
    end
  end
end
