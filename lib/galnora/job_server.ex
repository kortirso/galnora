defmodule Galnora.JobServer do
  @moduledoc false

  alias Galnora.{DB.Job, JobServer}

  @doc """
  Starts Job server
  """
  def start do
    spawn(&loop/0)
  end

  defp loop do
    receive do
      {:send_job, caller, job} ->
        IO.puts "Job server for job #{job.id} is started"
        job_server_pid = self()
        send(caller, {:send_job_result, {handle_job(job), job_server_pid}})
    end
    loop()
  end

  # handle job with systran service
  defp handle_job(%Job{type: :systran} = job), do: JobServer.Systran.call(job)
end
