defmodule Transforms.CombineTransform do

  require Logger

  def transform(list_of_keys1, list_of_values1, list_of_keys2, list_of_values2, params) do

    Logger.debug("In CombineTransform.transform, list_of_keys=#{inspect list_of_keys}, list_of_values=#{inspect list_of_values}, params=#{inspect params}")

    # Ignore the params as there are none for this type of transform

    # Ensure both list of values have the same list of keys otherwise cannot combine them
    cond do
      list_of_keys1 == list_of_keys2 ->
        Enum.concat(list_of_values1, list_of_values2)
    end

end
