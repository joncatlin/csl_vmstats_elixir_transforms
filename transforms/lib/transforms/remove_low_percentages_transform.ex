defmodule Transforms.RemoveLowPercentagesTransform do

  require Logger

  ## Constants
  @floor 1

  def transform(list_of_keys, list_of_values, params) do

    Logger.debug("In transform, list_of_keys=#{inspect list_of_keys}, list_of_values=#{inspect list_of_values}, params=#{inspect params}")

    # Get the params
    floor = Map.get(params, "floor", @floor)
    Logger.debug("get_param for floor matched: #{inspect floor}")

    # Set every value to zero that is equal to or below the floor value specified
    new_list_of_values = Enum.map(list_of_values, fn x ->
        if x <= floor do
          0.0
        else
          x
        end
      end)

    {list_of_keys, new_list_of_values}
  end

end
