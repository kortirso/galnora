defmodule GalnoraTest do
  use ExUnit.Case
  alias Galnora.{Server, DB.Job, DB.Queries}

  test "add and get messages" do
    clean_database()

    # create new job
    assert :ok == Server.add_job([{"###1###", "Hello"}], %{type: :systran, uid: 1, from: "en", to: "ru", keys: %{}})

    # wait job completeness and get this job by uid
    job = wait_job_completeness(1)

    assert %Job{type: :systran, uid: 1, status: :completed} = job

    clean_database()
  end

  defp wait_job_completeness(job_id) do
    job = Server.get_job(job_id)
    case job.status do
      :active ->
        Process.sleep(500)
        wait_job_completeness(job_id)
      _ ->
        job
    end
  end

  defp clean_database do
    Queries.Job.get_jobs()
    |> Enum.each(fn %Job{id: job_id} = job ->
      job_id |> Queries.Sentence.read_sentences() |> Enum.each(fn sentence -> Queries.Sentence.delete(sentence) end)
      Queries.Job.delete(job)
    end)
  end
end
