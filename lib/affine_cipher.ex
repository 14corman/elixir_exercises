defmodule Exercises.AffineCipher do

  @m 26
  @alphabet "abcdefghijklmnopqrstuvwxyz"

  @typedoc """
  A type for the encryption key
  """
  @type key() :: %{a: integer, b: integer}

  @doc """
  Encode an encrypted message using a key
  """
  @spec encode(key :: key(), message :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def encode(%{a: a, b: b}, message) do
    if is_coprime?(a) do
      {:ok, 
        message
        |> String.downcase()
        |> String.replace(~r/[\W_]/, "")
        |> String.graphemes()
        |> Enum.map(fn letter ->
          cond do
            Regex.match?(~r/^\d$/, letter) -> letter
            Enum.find(String.graphemes(@alphabet), fn x -> x == letter end) == nil -> letter
              letter -> 
                x = 
                @alphabet
                |> String.split(letter, parts: 2)
                |> List.first()
                |> String.length()

                y = rem((a * x) + b, @m) 
                new_letter = String.at(@alphabet, y)
                new_letter
            end
        end)
        |> Enum.chunk_every(5)
        |> Enum.join(" ")
      }
    else
      {:error, "a and m must be coprime."}
    end
  end

  @doc """
  Decode an encrypted message using a key
  """
  @spec decode(key :: key(), message :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def decode(%{a: a, b: b}, encrypted) do
    if is_coprime?(a) do
      {:ok, 
        encrypted
        |> String.downcase()
        |> String.replace(~r/[\W_]/, "")
        |> String.graphemes()
        |> Enum.map(fn letter ->
          cond do
            Regex.match?(~r/^\d$/, letter) -> letter
            letter -> 
              y = 
              @alphabet
              |> String.split(letter, parts: 2)
              |> List.first()
              |> String.length()

              x = rem(get_mmi(a) * (y - b), @m) 
              new_letter = String.at(@alphabet, x)
              new_letter
          end
        end)
        |> Enum.join("")
      }
    else
      {:error, "a and m must be coprime."}
    end
  end

  # While this does return nil, it never will as we only run this after we check if a & m are coprime.
  defp get_mmi(a) do
    Enum.find(1..@m, nil, fn n -> rem(a * n, @m) == 1 end)
  end

  defp is_coprime?(a), do: gcd(a, @m) == 1

  defp gcd(a, c) when a == 0 or c == 0, do: 0
  defp gcd(a, c) when a == c, do: a
  defp gcd(a, c) when a > c, do: gcd(a - c, c)
  defp gcd(a, c), do: gcd(a, c - a)
end