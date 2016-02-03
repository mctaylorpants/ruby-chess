module ChessHelpers
  # this is used to convert chess coordinates (e.g. a4) to standard x,y coords
  NUMBER_FOR_LETTER = { "a" => 1,
                        "b" => 2,
                        "c" => 3,
                        "d" => 4,
                        "e" => 5,
                        "f" => 6,
                        "g" => 7,
                        "h" => 8 }

  def coord_add(arr_1, arr_2)
    arr = []
    arr_1.each_with_index { |element, index| arr << arr_1[index] + arr_2[index] }
    arr # matey!
  end

  def coord_subtract(arr_1, arr_2)
    arr = []
    arr_1.each_with_index { |element, index| arr << arr_1[index] - arr_2[index] }
    arr
  end

  def array_pos_for(i)
    # offsets the coordinate position to return the correct element in the array.
    i - 1
  end

  def pos_for_coord(coord_string)
    # converts a board coordinate (e.g. a4) into a proper coordinate
    x = NUMBER_FOR_LETTER[coord_string[0]]
    y = coord_string[1].to_i
    [x, y]
  end

  def coord_for_pos(pos_arr)
    x = NUMBER_FOR_LETTER.invert[pos_arr[0]]
    y = pos_arr[1]
    "#{x}#{y}"
  end


end
