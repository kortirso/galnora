defmodule Galnora.DB.Queries.Job do
  @moduledoc false

  alias Galnora.DB.Job
  alias Memento.Query

  @doc """
  Get all jobs
  """
  def get_jobs do
    Memento.transaction! fn ->
      Query.all(Job)
    end
  end

  @doc """
  Get job by uid
  """
  def get_job_by_uid(uid) do
    run_select_query(
      {:==, :uid, uid}
    )
    |> Enum.at(0)
  end

  @doc """
  Create new job
  """
  def create(%{uid: uid, type: type, from: from, to: to, keys: keys}) do
    case get_job_by_uid(uid) do
      nil ->
        Memento.transaction! fn ->
          Query.write(%Job{status: :active, uid: uid, type: type, from: from, to: to, keys: keys})
        end
      _ ->
        {:error}
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
  Delete job
  """
  def delete(%Job{} = job) do
    Memento.transaction! fn ->
      Query.delete(Job, job.id)
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
