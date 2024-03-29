defmodule Galnora.DB.Queries.Sentence do
  @moduledoc false

  alias Galnora.DB.{Sentence, Queries.Job}
  alias Memento.Query

  @doc """
  Read all sentences by job's uid
  """
  def read_sentences(job_uid) do
    case Job.get_job_by_uid(job_uid) do
      nil -> []
      job ->
        run_select_query(
          {:==, :job_id, job.id}
        )
    end
  end

  @doc """
  Read all active sentences by job's uid
  """
  def read_active_sentences(job_uid) do
    case Job.get_job_by_uid(job_uid) do
      nil -> []
      job ->
        run_select_query(
          [
            {:==, :job_id, job.id},
            {:==, :output, ""}
          ]
        )
    end
  end

  @doc """
  Create new sentence
  """
  def create({uid, input}, job_id) do
    Memento.transaction! fn ->
      Query.write(%Sentence{uid: uid, input: input, output: "", job_id: job_id})
    end
  end

  @doc """
  Update sentence
  """
  def update(%Sentence{} = sentence) do
    Memento.transaction! fn ->
      Query.write(sentence)
    end
  end

  @doc """
  Delete sentence
  """
  def delete(%Sentence{} = sentence) do
    Memento.transaction! fn ->
      Query.delete(Sentence, sentence.id)
    end
  end

  defp run_select_query(pattern) do
    Memento.transaction! fn ->
      Query.select(Sentence, pattern)
    end
  end
end
