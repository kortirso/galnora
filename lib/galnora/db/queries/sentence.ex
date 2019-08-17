defmodule Galnora.DB.Queries.Sentence do
  @moduledoc false

  alias Galnora.DB.Sentence
  alias Memento.Query

  @doc """
  Read all sentences for job
  """
  def read_sentences(job_id) do
    run_select_query(
      {:==, :job_id, job_id}
    )
  end

  @doc """
  Read all active sentences for job
  """
  def read_active_sentences(job_id) do
    run_select_query(
      [
        {:==, :job_id, job_id},
        {:==, :output, ""}
      ]
    )
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

  defp run_select_query(pattern) do
    Memento.transaction! fn ->
      Query.select(Sentence, pattern)
    end
  end
end
