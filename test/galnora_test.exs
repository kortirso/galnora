defmodule GalnoraTest do
  use ExUnit.Case
  alias Galnora.{Server, DB.Job}

  test "add and get messages" do
    # delete old job
    old_job = Server.get_job(1)
    Server.delete_job(old_job.id)

    # create new job
    assert :ok == Server.add_job([], %{type: :systran, uid: 1, from: "en", to: "ru", keys: %{}})

    # and get this job by uid
    job = Server.get_job(1)

    assert %Job{type: :systran, uid: 1, status: :active} = job
  end
end
