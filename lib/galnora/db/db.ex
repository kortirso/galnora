defmodule Galnora.DB do
  @moduledoc false

  # Memento table definition
  defmodule Job do
    use Memento.Table,
      attributes: [:id, :type, :from, :to, :status, :keys],
      index: [:status],
      type: :ordered_set,
      autoincrement: true
  end

  defmodule Sentence do
    use Memento.Table,
      attributes: [:id, :uid, :input, :output, :job_id],
      index: [:job_id],
      type: :ordered_set,
      autoincrement: true
  end
end
