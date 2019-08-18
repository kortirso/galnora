defmodule GalnoraTest do
  use ExUnit.Case
  alias Galnora.{Server, DB.Job, DB.Queries}

  test "add and get messages" do
    # delete old job with sentences
    Queries.Job.get_jobs()
    |> Enum.each(fn %Job{id: job_id} = job ->
      job_id |> Queries.Sentence.read_sentences() |> Enum.each(fn sentence -> Queries.Sentence.delete(sentence) end)
      Queries.Job.delete(job)
    end)

    # create new job
    assert :ok == Server.add_job([{"###1###", "Hello"}], %{type: :systran, uid: 1, from: "en", to: "ru", keys: %{}})

    # and get this job by uid
    job = Server.get_job(1)
    # IO.inspect job

    sentences = Queries.Sentence.read_active_sentences(job.id)
    # IO.inspect sentences

    assert %Job{type: :systran, uid: 1, status: :active} = job
  end
end
