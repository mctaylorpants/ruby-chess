module ChessHelpers
  def coord_add(arr_1, arr_2)
    arr_1.each_with_index { |element, index| arr_1[index] += arr_2[index] }
  end
end
