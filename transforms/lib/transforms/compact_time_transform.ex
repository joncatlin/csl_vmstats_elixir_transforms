defmodule Transforms.CompactTimeTransform do

  require Logger

  ## Constants
#  @rolling_avg_length_default 10
  @time_period 15*60  # In seconds

  def transform(list_of_keys, list_of_values, params) do

    Logger.debug("In CompactTimeTransform, list_of_keys=#{inspect list_of_keys}, list_of_values=#{inspect list_of_values}, params=#{inspect params}")

    # Get the params
    time_period = Map.get(params, "time_period", @time_period)
    Logger.debug("get_param for time_period matched: #{inspect time_period}")

    index = 0

    # Need to determine what the first time period is. Also need to cover the situation where there is a gap in the time periods in the list of keys
    start_period = calc_time_period(Enum.at(list_of_keys, 0), time_period)

    # Recurse through the lists compacting the values into a single number for each time_period increment
    new_values = compact(list_of_keys, list_of_values, time_period, start_period, 0, [], [])

  end


  defp compact([keys_head | keys_tail], [values_head | values_tail], time_period, running_time_period, time_period_total, new_keys, new_values) do

    Logger.debug("In compact keys_head=#{inspect keys_head}, values_head=#{inspect values_head}, running_time_period=#{inspect running_time_period}")

    if keys_head >= running_time_period do
      Logger.debug("In compact outside running_time_period")
      # time period has changed so add the running total to the new_values
      temp_values = new_values ++ [time_period_total]
      temp_keys = new_keys ++ [running_time_period - time_period]
#      new_running_time_period = running_time_period + time_period
      new_running_time_period = calc_time_period(keys_head, time_period)
      compact(keys_tail, values_tail, time_period, new_running_time_period, values_head, temp_keys, temp_values)
    else
      Logger.debug("In compact inside running_time_period")
      # Update the running total
      new_time_period_total = time_period_total + values_head
      compact(keys_tail, values_tail, time_period, running_time_period, new_time_period_total, new_keys, new_values)
    end
  end


  defp compact([], _, time_period, running_time_period, time_period_total, new_keys, new_values) do
    Logger.debug("In compact end of recursion")
    temp_values = new_values ++ [time_period_total]
    temp_keys = new_keys ++ [running_time_period - time_period]
    {temp_keys, temp_values}
  end


  defp calc_time_period(x, time_period) do
    trunc((x + time_period) / time_period) * time_period
  end

end




