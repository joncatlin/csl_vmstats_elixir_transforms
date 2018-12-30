defmodule TransformsTest do
  use ExUnit.Case
  doctest Transforms

  require Logger

  @empty_params %{}

  # sample data for tyhe base noise transform
  @list_of_keys1 [1..20]
  @list_of_values1 [1,1,1,0,1,2,2,3,3,5,5,1,0,0,2,2,2,2,2,2]
  @list_of_values2 [10,10,10,0,10,20,20,30,30,50,50,100,0,0,20,20,20,20,80,40]
  @list_of_values3 [100,100,100,0,100,200,200,300,300,500,500,1000,0,0,200,200,200,200,800,400]


  defp get_data(machine, date, type) do

    # convert the date into the correct form
    [month, day, year] = String.split(date, "/")
    {:ok, date_struct} = Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))

    # get the requested data from the appropriate store
    state = DataPointsStore.start(machine, date_struct)
    ret_data = DataPointsStore.get(type, state)

    # convert the data to a sorted list
    Logger.debug("Data returned from store is :#{inspect ret_data}")

    # convert the data to something useable
    {_, {list_of_keys, list_of_values}} = Enum.to_list(ret_data)
      |> Enum.sort(fn({key1, value1}, {key2, value2}) -> key1 < key2 end)
      |> Enum.map_reduce({[], []}, fn {k, v}, acc ->
        {keys, values} = acc
        new_keys = keys ++ [k]
        new_values = values ++ [v]
        {[], {new_keys, new_values}}
      end)

    Logger.debug("list_of_keys=#{inspect list_of_keys}, list_of_values=#{inspect list_of_values}")
    {list_of_keys, list_of_values}
  end


  test "RemoveBaseNoiseTransform using small sample of values and rolling_avg_length=3" do

    # # Define the parameters for the transform
    # {list_of_keys, list_of_values} = get_data("V-BWilliford", "10/1/2018", "cpu_avg")

    {new_list_of_keys, new_list_of_values} = Transforms.RemoveBaseNoiseTransform.transform(@list_of_keys1, @list_of_values1, %{"rolling_avg_length" => 3})
    Logger.debug("new_list_of_keys=#{inspect new_list_of_keys}, new_list_of_values=#{inspect new_list_of_values}")
    assert new_list_of_keys == @list_of_keys1
    avg = 1/3
    assert new_list_of_values == [1-avg,1-avg,1-avg,0,1-avg,2-avg,2-avg,3-avg,3-avg,5-avg,5-avg,1-avg,0,0,2-avg,2-avg,2-avg,2-avg,2-avg,2-avg]

  end


  test "RemoveBaseNoiseTransform using small sample of values and rolling_avg_length=5" do

    # # Define the parameters for the transform
    # {list_of_keys, list_of_values} = get_data("V-BWilliford", "10/1/2018", "cpu_avg")

    {new_list_of_keys, new_list_of_values} = Transforms.RemoveBaseNoiseTransform.transform(@list_of_keys1, @list_of_values1, %{"rolling_avg_length" => 5})
    Logger.debug("new_list_of_keys=#{inspect new_list_of_keys}, new_list_of_values=#{inspect new_list_of_values}")
    assert new_list_of_keys == @list_of_keys1
    avg = 4/5
    assert new_list_of_values == [1-avg,1-avg,1-avg,0,1-avg,2-avg,2-avg,3-avg,3-avg,5-avg,5-avg,1-avg,0,0,2-avg,2-avg,2-avg,2-avg,2-avg,2-avg]

  end


  test "RemoveBaseNoiseTransform using small sample of values and rolling_avg_length=default" do

    # # Define the parameters for the transform
    # {list_of_keys, list_of_values} = get_data("V-BWilliford", "10/1/2018", "cpu_avg")

    {new_list_of_keys, new_list_of_values} = Transforms.RemoveBaseNoiseTransform.transform(@list_of_keys1, @list_of_values1, @empty_params)
    Logger.debug("new_list_of_keys=#{inspect new_list_of_keys}, new_list_of_values=#{inspect new_list_of_values}")
    assert new_list_of_keys == @list_of_keys1
    avg = 18/10
    assert new_list_of_values == [0,0,0,0,0,2-avg,2-avg,3-avg,3-avg,5-avg,5-avg,0,0,0,2-avg,2-avg,2-avg,2-avg,2-avg,2-avg]
  end


  test "PercentizeTransform using sample @list_of_values2" do

    {new_list_of_keys, new_list_of_values} = Transforms.PercentizeTransform.transform(@list_of_keys1, @list_of_values2, @empty_params)
    Logger.debug("new_list_of_keys=#{inspect new_list_of_keys}, new_list_of_values=#{inspect new_list_of_values}")
    assert new_list_of_keys == @list_of_keys1
    assert new_list_of_values == @list_of_values2
  end


  test "PercentizeTransform using sample @list_of_values3" do

    {new_list_of_keys, new_list_of_values} = Transforms.PercentizeTransform.transform(@list_of_keys1, @list_of_values3, @empty_params)
    Logger.debug("new_list_of_keys=#{inspect new_list_of_keys}, new_list_of_values=#{inspect new_list_of_values}")
    assert new_list_of_keys == @list_of_keys1
    assert new_list_of_values == @list_of_values2 # Yes this is correct as list_of_values3 is 10 times larger values than list_of_values2
  end

end
