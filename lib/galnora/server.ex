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

    # pool = Job.get_active_jobs() |> Enum.map(fn job -> start_job_server(job) end)

    {:ok, %{pool: []}}
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
  Deletes job by uid with sentences
  """
  def handle_cast({:delete_job, uid}, state) do
    case Job.get_job_by_uid(uid) do
      nil -> nil
      job ->
        Job.delete(job)
        job.id |> Sentence.read_sentences() |> Enum.each(fn sentence -> Sentence.delete(sentence) end)
    end

    {:noreply, state}
  end

  @doc """
  Returns job by uid
  """
  def handle_call({:get_job, uid}, _, state), do: {:reply, Job.get_job_by_uid(uid), state}

  @doc """
  Returns job by uid
  """
  def handle_call({:get_job_with_sentences, uid}, _, state) do
    result = uid |> Sentence.read_sentences() |> Enum.map(fn sentence -> {sentence.uid, sentence.input, sentence.output} end)

    {:reply, result, state}
  end

  @doc """
  Receives translation result
  """
  def handle_info({:send_job_result, {{result, job}, job_server_pid}}, state) do
    IO.puts "Galnora server is receiving result for job #{job.id}"
    status = if result == :ok, do: :completed, else: :failed

    job |> Map.merge(%{status: status}) |> Job.update()
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
  Render job's sentences by job's uid
  """
  def get_job_with_sentences(uid) when is_integer(uid), do: GenServer.call(__MODULE__, {:get_job_with_sentences, uid})

  @doc """
  Delete job by uid
  """
  def delete_job(uid) when is_integer(uid), do: GenServer.cast(__MODULE__, {:delete_job, uid})
end
