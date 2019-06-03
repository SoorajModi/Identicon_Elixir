defmodule Identicon do
  @moduledoc """
    Documentation for Identicon.
  """

  def main(input) do
    input
    |> hash_input
    |> pick_colour
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
     Filters odd elements out of the array.
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
     Builds the final element of image struct, the grid.
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)    # splits integer list into 3 part chunks
      |> Enum.map(&mirror_row/1)   # & means we are going to be passing a reference
      |> List.flatten
      |> Enum.with_index          # turns every element in list to two element tuple

    %Identicon.Image{image | grid: grid}
  end

  @doc """
     Appends the first two elements of a list to the end of the list

  ## Examples

       iex> Identicon.mirror_row([1, 2, 3])
       [1, 2, 3, 2, 1]

  """
  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  @doc """
     Takes the first three elements of the list and sets them equal to colour

  ## Examples

       iex> Identicon.pick_colour(%Identicon.Image{
       ...> colour: nil,
       ...> grid: nil,
       ...> hex: [238, 36, 65, 25, 22, 177, 16, 117, 52, 29, 28, 154, 83, 190, 37, 86]
       ...> })
       %Identicon.Image{
         colour: {238, 36, 65},
         grid: nil,
         hex: [238, 36, 65, 25, 22, 177, 16, 117, 52, 29, 28, 154, 83, 190, 37, 86]
       }

  """ # As we receive the image as an arg, we are also pattern matching out of the arguement
  def pick_colour(
        %Identicon.Image{hex: [r, g, b | _tail]} = image
      ) do
    %Identicon.Image{image | colour: {r, g, b}}
  end

  @doc """
      Convert a string into an unique sequence of characters

  ## Examples

       iex> Identicon.hash_input("user_input")
       %Identicon.Image{
         colour: nil,
         grid: nil,
         hex: [238, 36, 65, 25, 22, 177, 16, 117, 52, 29, 28, 154, 83, 190, 37, 86]
       }

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
          |> :binary.bin_to_list

    %Identicon.Image{hex: hex}    # Now returning struct
  end
end
