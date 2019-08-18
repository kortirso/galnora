defmodule Galnora.JobServer.Systran do
  @moduledoc false

  alias Galnora.DB.{Job, Sentence, Queries}
  alias Systran.Translate

  @doc """
  Translate

  ## Examples

      iex> Galnora.JobServer.Systran.call(job)

  """
  def call(%Job{id: job_id, from: from, to: to, keys: keys} = job) do
    # define key for translations
    key = if keys[:key] == nil, do: Application.get_env(:systran, :api_key), else: keys[:key]
    job_id
    |> Queries.Sentence.read_active_sentences()
    |> Enum.map(fn %Sentence{input: input} = sentence ->
      IO.inspect sentence
      # translate input text
      output = translate(key, input, from, to, 0)
      IO.inspect output
      # update sentence
      sentence |> Map.merge(%{output: output}) |> Queries.Sentence.update()
    end)
    {:ok, job}
  end

  def call(job), do: {:error, job}

  defp translate(_, input, _, _, 3), do: "#{input}---"

  defp translate(key, input, source, target, index) do
    case Translate.translate(%{key: key, input: input, source: source, target: target}) do
      {:error, :timeout} ->
        Process.sleep(500)
        translate(key, input, source, target, index + 1)
      {:error, _} ->
        "#{input}---"
      {:ok, result} ->
        result["outputs"]
        |> Enum.at(0)
        |> Map.get("output")
    end
  end
end
