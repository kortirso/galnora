defmodule Galnora.Server do
  @moduledoc false

  use GenServer
  alias Galnora.DB.Queries.{Job, Sentence}

  # GenServer API

  @doc """
  Init server
  """
  def init(_) do
    IO.puts "Galnora server is running"
    jobs = Job.active_jobs

    {:ok, %{jobs: jobs}}
  end

  @doc """
  Take first job from state
  """
  def handle_call(:take_job, _, state) do
    {job, jobs} = do_take_job(state.jobs)

    {:reply, job, %{jobs: jobs}}
  end

  @doc """
  Return list of jobs in the state
  """
  def handle_call(:list_jobs, _, state), do: {:reply, state.jobs, state}

  defp do_take_job([job | jobs]), do: {job, jobs}
  defp do_take_job([]), do: {nil, []}

  @doc """
  Add job to state
  """
  def handle_cast({:add_job, sentences, value}, state) do
    job = Job.create(value)
    sentences
    |> Enum.each(fn sentence ->
      Sentence.create(sentence, job.id)
    end)

    {:noreply, %{jobs: place_value_to_end(job, state.jobs)}}
  end

  defp place_value_to_end(addition, jobs) do
    [addition | Enum.reverse(jobs)] |> Enum.reverse()
  end

  @doc """
  Handle terminating
  """
  def terminate do
    IO.puts "Galnora server is shutting down"
  end

  # Client API

  @doc """
  Starts the Supervision Tree
  """
  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  @doc """
  Render list jobs
  """
  def list_jobs, do: GenServer.call(__MODULE__, :list_jobs)

  @doc """
  Add job to the state
  """
  def add_job(sentences, value), do: GenServer.cast(__MODULE__, {:add_job, sentences, value})

  @doc """
  Take first job from the state
  """
  def take_job, do: GenServer.call(__MODULE__, :take_job)
end
