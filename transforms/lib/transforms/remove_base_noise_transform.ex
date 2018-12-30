defmodule Transforms.RemoveBaseNoiseTransform do

  require Logger

  ## Constants
  @rolling_avg_length_default 10

  def transform(list_of_keys, list_of_values, params) do

    Logger.debug("In transform, list_of_keys=#{inspect list_of_keys}, list_of_values=#{inspect list_of_values}, params=#{inspect params}")

    # Get the params
    rolling_avg_length = Map.get(params, "rolling_avg_length", @rolling_avg_length_default)
    Logger.debug("get_param for rolling_avg_length matched: #{inspect rolling_avg_length}")

    index = 0

    # Find the value for the base noise
    base_noise = find_lowest_rolling_avg(list_of_values, index, rolling_avg_length)

    # Subtract the base noise from each of the values
    new_list_of_values = Enum.map(list_of_values, fn x ->
      max(0, x - base_noise)
      end)
    {list_of_keys, new_list_of_values}
  end


  defp find_lowest_rolling_avg(list_of_values, index, rolling_avg_length) do

    Logger.debug("In find_lowest_rolling_avg, index=#{inspect index}, rolling_avg_length=#{inspect rolling_avg_length},
      list_of_values.length=#{inspect length(list_of_values)}")

    # Calculate the sum for the first set of values, the size of the set is determined by rolling_avg_length
    sum = list_of_values
      |> Enum.take(rolling_avg_length)
      |> Enum.sum()

    # calculate the starting average
    avg = sum / rolling_avg_length

    # calculate the averages for the rest of the data and pick the smallest
    # use a rolling calculation that takes a set of the values the size of the
    # rolling_avg_length and removes one at the begging and adds one at the end
    # then calculates the sum and avg. If the avg just calculated is smaller than
    # the previous calculation take that and pass it on to the next iteration
    {final_avg, final_sum, final_index} = Enum.drop(list_of_values, rolling_avg_length)
      |> Enum.reduce({avg, sum, rolling_avg_length}, fn _, acc ->
        {curr_avg, curr_sum, curr_index} = acc
        temp_sum = curr_sum - Enum.at(list_of_values, curr_index - rolling_avg_length) + Enum.at(list_of_values, curr_index)
        temp_avg = temp_sum / rolling_avg_length
        new_avg = min(curr_avg, temp_avg)
        {new_avg, temp_sum, curr_index + 1}
      end)

    Logger.debug("In find_lowest_rolling_avg, final_avg=#{inspect final_avg}, final_sum=#{inspect final_sum}, final_index=#{inspect final_index}")

    final_avg
  end

end
