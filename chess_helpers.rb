module ChessHelpers
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


end
