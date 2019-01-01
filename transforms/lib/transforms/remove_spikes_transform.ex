defmodule Transforms.RemoveSpikesTransform do

  require Logger

  ## Constants
  @base_window_length 1
  @spike_window_length 1
  @base_value 0

  def transform(list_of_keys, list_of_values, params) do

    Logger.debug("In RemoveSpikesTransform.transform, list_of_keys=#{inspect list_of_keys}, list_of_values=#{inspect list_of_values}, params=#{inspect params}")

    # Get the params
    base_window_length = Map.get(params, "base_window_length", @base_window_length)
    Logger.debug("get_param for base_window_length matched: #{inspect base_window_length}")

    spike_window_length = Map.get(params, "spike_window_length", @spike_window_length)
    Logger.debug("get_param for spike_window_length matched: #{inspect spike_window_length}")

    # Starting with the first value in the list_of_values, compare the value and the next ones in sequence to see if they match the spike deinition
    # if it does then set the values to the base_value specified
    new_list_of_values = find_spikes(list_of_values, @base_value, base_window_length, spike_window_length)

    {list_of_keys, new_list_of_values}
  end


  # Look for spikes in the values starting at the head of the list. If no spike is found then move to the
  # next value in the list of values
  # End of the recursive check for spikes in the values
  defp find_spikes([], base_value, base_window_length, spike_window_length) do
    Logger.debug("In find_spikes, at end of recursion")
    [] # return an empty list so it is the last thing concatrenated to the list_of_values processed
  end


  defp find_spikes([head | tail], base_value, base_window_length, spike_window_length) do
    result = is_spike(head, tail, 0, base_window_length, spike_window_length, base_value, [])
    case result do
      {true, new_values} ->
        Logger.debug("In find_spikes, found spike at value=#{inspect head}, tail=#{inspect tail}")
        new_values ++ find_spikes(Enum.drop(tail, base_window_length + spike_window_length - 1), base_value, base_window_length, spike_window_length)
      _ ->
        [head] ++ find_spikes(tail, base_value, base_window_length, spike_window_length)
    end
  end


  # End of the recursive checking for a spike
  defp is_spike(head, [], index, base_window_length, spike_window_length, base_value, new_values) do
    Logger.debug("In is_spike, END of recursion head=#{inspect head}, index=#{inspect index}, new_values=#{inspect new_values}")
    if index >= (2 * base_window_length) + spike_window_length - 1 do
#      Logger.debug("In is_spike, returning TRUE at value=#{inspect head}, index=#{inspect index}")
      # Only if we have finished checking the windows worth of values can it be a spike
      {true, new_values}
    else
      # All other possibilities means this cannot be a spike there is no data left to check
#      Logger.debug("In is_spike, returning FALSE at value=#{inspect head}, index=#{inspect index}")
      {false}
    end

  end


  # when checking for a spike return the data it would be if it were a spike and if false then just return nothing. That way we do not have to process the list twice.
  defp is_spike(head, tail, index, base_window_length, spike_window_length, base_value, new_values) do
    Logger.debug("In is_spike, head=#{inspect head}, tail=#{inspect tail}, index=#{inspect index}, new_values=#{inspect new_values}")
    cond do
      index < base_window_length ->
        # As long as the head_values is a base value then contine looking for spikes
        if head == base_value do
#          Logger.debug("In is_spike, index < base_window_length && head==base_value so still looking value=#{inspect head}, index=#{inspect index}")
          is_spike(hd(tail), tl(tail), index+1, base_window_length, spike_window_length, base_value, new_values ++ [base_value])
        else
#          Logger.debug("In is_spike, index < base_window_length && head!=base_value so no spike found value=#{inspect head}, index=#{inspect index}")
          {false}
        end

      index < base_window_length + spike_window_length ->
#        Logger.debug("In is_spike, index < base_window_length + spike_window_length so still looking value=#{inspect head}, index=#{inspect index}")
        # Regardless of the value keep looking as a spike may only have a single value aove base in the spike_window
        is_spike(hd(tail), tl(tail), index+1, base_window_length, spike_window_length, base_value, new_values ++ [base_value])

      index <= base_window_length + spike_window_length + base_window_length - 1 ->
        # As long as the head_values is a base value then contine looking for spikes
        if head == base_value do
#          Logger.debug("In is_spike, index < base_window_length + spike_window_length + base_window_length && head==base so still looking value=#{inspect head}, index=#{inspect index}")
          is_spike(hd(tail), tl(tail), index+1, base_window_length, spike_window_length, base_value, new_values) # do not add values for anything beyond the spike
        else
#          Logger.debug("In is_spike, index < base_window_length + spike_window_length + base_window_length && head!=base so no spike found value=#{inspect head}, index=#{inspect index}")
          {false}
        end

      true ->
        Logger.debug("In is_spike, run out of values to check so must be a spike, new_values=#{inspect new_values}")
        {true, new_values} # Run out of values to check so must be a spike, so return true
    end
  end



end
