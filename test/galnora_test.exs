defmodule GalnoraTest do
  use ExUnit.Case
  alias Galnora.{Server, DB.Job}

  test "add/read/get messages" do
    assert :ok == Server.add_job([], %{type: :systran, uid: 1, from: "en", to: "ru", keys: %{}})

    # and read them
    jobs = Server.list_jobs

    assert is_list(jobs)

    # and get first message
    job = Server.take_job

    assert %Job{type: :systran, uid: 1, status: :active} = job
  end
end
