defmodule Transforms.CombineTransform do

  require Logger

  def transform(list_of_keys1, list_of_values1, list_of_keys2, list_of_values2, params) do

    Logger.debug("In CombineTransform.transform, list_of_keys1=#{inspect list_of_keys1}, list_of_values1=#{inspect list_of_values1}, \
      list_of_keys2=#{inspect list_of_keys2}, list_of_values2=#{inspect list_of_values2}, \
      params=#{inspect params}")

    # Ignore the params as there are none for this type of transform

    # Ensure both list of values have the same list of keys otherwise cannot combine them
    {new_list_of_values, _} = cond do
      list_of_keys1 == list_of_keys2 ->
        Enum.reduce(list_of_values1, {[], 0}, fn x, acc ->
          {curr_list, index} = acc
          y = x + Enum.at(list_of_values2, index)
          new_list = curr_list ++ [y]
          {new_list, index + 1}
        end)
      true -> {[], nil}
      end

    {list_of_keys1, new_list_of_values}
  end

end
