defmodule Galnora.JobServer do
  @moduledoc false

  @doc """
  Starts Job server
  """
  def start do
    spawn(&loop/0)
  end

  defp loop do
    receive do
      {:send_job, caller, job} ->
        send(caller, {:send_job_result, handle_job(job)})
    end
    loop()
  end

  # make virtual job sending
  defp handle_job(job), do: 5 |> :rand.uniform() |> do_handle_job(job)

  defp do_handle_job(1, job), do: {:error, job}
  defp do_handle_job(_, job), do: {:ok, job}
end
