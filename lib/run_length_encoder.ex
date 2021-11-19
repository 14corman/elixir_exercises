defmodule Exercises.RunLengthEncoder do
  @doc """
  Generates a string where consecutive elements are represented as a data value and count.
  "AABBBCCCC" => "2A3B4C"
  For this example, assume all input are strings, that are all uppercase letters.
  It should also be able to reconstruct the data into its original form.
  "2A3B4C" => "AABBBCCCC"
  """

  @spec encode(String.t) :: String.t
  def encode(string) do
    string
    |> String.graphemes()
    |> Enum.reduce({"", {0, nil}}, fn char, {acc, {curr_count, curr_char}} = total_acc -> 
      cond do
        is_nil(curr_char) -> {acc, {1, char}}
        curr_char == char -> {acc, {curr_count + 1, curr_char}}
        curr_char != char -> add_encoding(total_acc, char)
      end
    end)
    |> add_encoding(nil)
    |> elem(0)
  end

  @spec decode(String.t) :: String.t
  def decode(string) do
    Regex.scan(~r/(\d*)(.)/, string)
    |> Enum.reduce("", fn [_group, count, char], acc -> 
      parsed_count =
        case count do
          "" -> 1
          _ -> String.to_integer(count)
        end

      acc <> String.duplicate(char, parsed_count)
    end)
  end

  defp add_encoding({acc, {0, curr_char}}, char), do:          {acc, {1, char}}
  defp add_encoding({acc, {1, curr_char}}, char), do:          {acc <> curr_char, {1, char}}
  defp add_encoding({acc, {curr_count, curr_char}}, char), do: {acc <> "#{curr_count}#{curr_char}", {1, char}}
end