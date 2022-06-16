defmodule Exercises.Frequency do
  @doc """
  Count letter frequency in parallel.
  Returns a map of characters to frequencies.
  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, workers) do

    # Join texts in list and remove numbers and non-characters
    texts = 
      texts
      |> Enum.join(" ")
      |> String.graphemes()
      |> Enum.filter(& String.match?(&1, ~r/\w/u))
      |> Enum.filter(& String.match?(&1, ~r/[^\d]/u))

    # Check if there are not enough characters for the workers requested
    text_length = length(texts)
    workers = 
      if text_length < workers do
        text_length
      else
        workers
      end

    if texts == [] do
      %{}
    else
      texts = Enum.chunk_every(texts, trunc(Float.ceil(text_length / workers)))

      0..(workers - 1)
      |> Enum.map(& freq_worker(&1, texts))
      |> Enum.reduce(%{}, fn _, current_map -> get_result(current_map) end)
    end
  end

  defp freq_worker(id, texts) do
    caller = self

    spawn(
      fn -> 
        result =
          texts
          |> Enum.at(id)
          |> Enum.map(&String.downcase/1)
          |> Enum.reduce(%{}, fn
            " ", cur_result -> cur_result 
            char, cur_result -> Map.update(cur_result, char, 1, & &1 + 1)
          end)
      
        send(caller, {:result, result})
      end
    )
  end

  defp get_result(current_map) do
    receive do
      {:result, result} -> Map.merge(result, current_map, fn _key, m1, m2 -> m1 + m2 end)
    end
  end
end