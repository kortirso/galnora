defmodule Galnora.Server do
  @moduledoc false

  use GenServer
  alias Galnora.DB.Queries.{Job, Sentence}
  alias Galnora.JobServer

  # GenServer API

  @doc """
  Inits server
  """
  def init(_) do
    IO.puts "Galnora server is running"

    pool = Job.active_jobs() |> Enum.map(fn job -> start_job_server(job) end)

    {:ok, %{pool: pool}}
  end

  @doc """
  Add job to state
  """
  def handle_cast({:add_job, sentences, value}, state) do
    case Job.create(value) do
      {:error} ->
        {:noreply, state}
      job ->
        sentences |> Enum.each(fn sentence -> Sentence.create(sentence, job.id) end)
        {:noreply, %{pool: job |> start_job_server() |> place_value_to_pool(state.pool)}}
    end
  end

  @doc """
  Deletes job by uid
  """
  def handle_cast({:delete_job, uid}, state) do
    case Job.get_job_by_uid(uid) do
      nil ->
        nil
      job ->
        Job.delete(job)
    end

    {:noreply, state}
  end

  @doc """
  Returns job by uid
  """
  def handle_call({:get_job, uid}, _, state), do: {:reply, Job.get_job_by_uid(uid), state}

  @doc """
  Receives sending result with error
  """
  def handle_info({:send_job_result, {:error, job}, job_server_pid}, state) do
    job |> Map.merge(%{status: :failed}) |> Job.update()
    stop_server(job_server_pid)

    {:noreply, %{pool: state.pool |> List.delete(job_server_pid)}}
  end

  @doc """
  Receives sending result with success
  """
  def handle_info({:send_job_result, {:ok, job}, job_server_pid}, state) do
    job |> Map.merge(%{status: :completed}) |> Job.update()
    stop_server(job_server_pid)

    {:noreply, %{pool: state.pool |> List.delete(job_server_pid)}}
  end

  @doc """
  Handle terminating
  """
  def terminate(_, state) do
    IO.puts "Galnora server is shutting down"
    cleanup(state)
  end

  # private functions
  defp start_job_server(job) do
    job_server_pid = JobServer.start
    caller = self()
    send(job_server_pid, {:send_job, caller, job})

    job_server_pid
  end

  defp place_value_to_pool(addition, pool), do: [addition | pool]

  defp cleanup(%{pool: pool}) do
    pool |> Enum.each(fn server_pid -> stop_server(server_pid)end)
    IO.puts "All job servers are closed"
  end

  defp stop_server(server_pid), do: Process.exit(server_pid, :terminating)

  # Client API

  @doc """
  Starts the Supervision Tree
  """
  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  @doc """
  Add job to the state
  """
  def add_job(sentences, value) when is_list(sentences) and is_map(value), do: GenServer.cast(__MODULE__, {:add_job, sentences, value})

  @doc """
  Render job by uid
  """
  def get_job(uid) when is_integer(uid), do: GenServer.call(__MODULE__, {:get_job, uid})

  @doc """
  Delete job by uid
  """
  def delete_job(uid) when is_integer(uid), do: GenServer.cast(__MODULE__, {:delete_job, uid})
end
