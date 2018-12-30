defmodule Transforms.PercentizeTransform do

  require Logger

  def transform(list_of_keys, list_of_values, params) do

    Logger.debug("In PercentizeTransform.transform, list_of_keys=#{inspect list_of_keys}, list_of_values=#{inspect list_of_values}, params=#{inspect params}")

    # Ignore the params as there are none for this type of transform

    {_, {min, max}} = Enum.map_reduce(list_of_values, {Enum.at(list_of_values, 0), 0}, fn x, acc ->
      {curr_min, curr_max} = acc
      new_min = min(curr_min, x)
      new_max = max(curr_max, x)
      {nil, {new_min, new_max}}
    end)

    Logger.debug("In PercentizeTransform.transform, min=#{inspect min}, max=#{inspect max}")

    new_list_of_values = Enum.map(list_of_values, fn x -> max(0, (x - min) / max * 100) end)
    {list_of_keys, new_list_of_values}
  end

end
