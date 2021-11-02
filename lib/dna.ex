defmodule Exercises.DNA do
  @moduledoc """
  Code for (DNA Encoding exercise)[https://exercism.org/tracks/elixir/exercises/dna-encoding] 
  from Exercism .
  """

  @doc """
    Non-recursive option to encode a DNA string into a bitstring.

    CAN ONLY BE USED WITH `&decode/1`.

    ## Example:
    iex >> Exercises.DNA.encode("AGTC AG T")
    <<1, 4, 8, 2, 0, 1, 4, 0, 8>>
  """
  def encode(nas) do
    nas
    |> to_charlist()
    |> Enum.map(&encode_nucleotide/1)
    |> :binary.list_to_bin()
  end

  @doc """
    Non-recursive option to decode a bitstring into a DNA string.

    CAN ONLY BE USED WITH `&encode/1`.

    ## Example:
    iex >> Exercises.DNA.decode(<<1, 4, 8, 2, 0, 1, 4, 0, 8>>)
    "AGTC AG T"
  """
  def decode(bitstring) do
    bitstring
    |> :binary.bin_to_list()
    |> Enum.map(&decode_nucleotide/1)
    |> to_string()
  end

  @doc """
    Recursive-ish option to encode a DNA string into a bitstring.
    Uses tail recursion in the background like:
        ``` Enum.reduce(['a', 'b', 'c', 'd', 'e', 'f'], [], &f/2) ```
        >> f('f', f('e', f('d', f('c', f('b', f('a', []))))))

    CAN ONLY BE USED WITH `&decode_rec/1`.

    ## Example:
    iex >> Exercises.DNA.encode_rec("AGTC AG T")
    <<20, 130, 1, 64, 8::size(4)>>
  """
  def encode_rec(nas) do
    nas
    |> to_charlist()
    |> Enum.reduce(<<>>, fn na, acc -> 
      <<acc::bitstring, encode_nucleotide(na)::4>>
    end)
  end

  @doc """
    Recursive option to decode a bitstring into a DNA string.

    CAN ONLY BE USED WITH `&encode_rec/1`.

    ## Example:
    iex >> Exercises.DNA.decode_rec(<<20, 130, 1, 64, 8::size(4)>>)
    'AGTC AG T'
  """
  def decode_rec(bitstring) do
    []
    |> decode_helper(bitstring)
    |> Enum.reverse()
  end

  # Decode helper that recursively breaks down bitstring into characters.
  defp decode_helper(acc, <<>>), do: acc
  defp decode_helper(acc, <<na::4, rest::bitstring>>) do
    new_acc = [decode_nucleotide(na) | acc]
    decode_helper(new_acc, rest)
  end
  
  # Helper functions that use pattern matching to encode or decode inputs.
  defp encode_nucleotide(?\s), do:  0b0000
  defp encode_nucleotide(?A), do: 0b0001
  defp encode_nucleotide(?C), do: 0b0010
  defp encode_nucleotide(?G), do: 0b0100
  defp encode_nucleotide(?T), do: 0b1000

  defp decode_nucleotide(0b0000), do: ?\s
  defp decode_nucleotide(0b0001), do: ?A
  defp decode_nucleotide(0b0010), do: ?C
  defp decode_nucleotide(0b0100), do: ?G
  defp decode_nucleotide(0b1000), do: ?T
end
