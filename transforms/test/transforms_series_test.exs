defmodule TransformsSeriesTest do
  use ExUnit.Case
  doctest Transforms

  require Logger

  @empty_params %{}

  # sample data for tyhe base noise transform
  @list_of_keys1 [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
  @list_of_values1 [1,1,1,0,1,2,2,3,3,5,5,1,0,0,2,2,2,2,2,2]
  @list_of_values2 [10,10,10,0,10,20,20,30,30,50,50,100,0,0,20,20,20,20,80,40]
  @list_of_values3 [100,100,100,0,100,200,200,300,300,500,500,1000,0,0,200,200,200,200,800,400]

  @list_of_keys2   [3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18]
  @list_of_values4 [1, 1, 0, 1, 2, 2, 3, 3,   5,  1,  0,  0,  2,  2,  2]

  @list_of_keys3   [3, 4, 5, 11, 12, 13, 18]
  @list_of_values5 [1, 1, 3,  5,  1,  0,  2]

  @list_of_values6 [1,1,1,0,1,0,2,3,0,5,0,1,0,0,2,0,2,2,2,2]
  @list_of_values7 [0,0,1,0,1,0,0,3,0,0,0,1,6,0,0,0,2,0,0,2]
  @list_of_values8 [0,0,1,0,1,0,0,3,0,0,0,1,6,0,0,0,2,6,0,0]

  test "Success - Create a metric struct" do

    # Create the expected result
    valid_metric = %Transforms.Metric{name: "mem_avg", keys: @list_of_keys1, values: @list_of_values1}

    # Create a metric
    {status, metric} = Transforms.Metric.create("mem_avg", @list_of_keys1, @list_of_values1)
    assert status == :ok, "Error - metric creation failed, the value returned for the metric is: #{inspect metric}"
    assert metric == valid_metric
end


  test "Success - Create a transform struct" do

    valid_transform = %Transforms.Transform{
        func: &Transforms.CombineTransform.transform/5,
        name: "combine",
        parameters: %{}
      }

    # Create a transform
    {status, transform} = Transforms.Transform.create("combine")
    assert status == :ok, "Error - transform creation failed, the value returned for the transform is: #{inspect transform}"
    assert transform == valid_transform
  end


  test "Failure - Create a transform struct with bad transform name" do

    # Create a transform
    {status, transform} = Transforms.Transform.create("tbd", {"param1", 23})
    assert status == :error

  end


  test "Success - Create a transform struct with good parameter name" do

    valid_transform = %Transforms.Transform{
        func: &Transforms.CompactTimeTransform.transform/3,
        name: "compact_time",
        parameters: %{"time_period" => 23}
      }

    # Create a transform
    {status, transform} = Transforms.Transform.create("compact_time", %{"time_period" => 23})
    assert status == :ok
    assert transform == valid_transform
  end


  test "Failure - Create a transform struct with bad parameter name" do

    # Create a transform
    {status, transform} = Transforms.Transform.create("compact_time", %{"times_period" => 23})
    assert status == :error
  end


  test "Failure - Create a transform struct with one bad parameter name and one good name" do

    # Create a transform
    {status, transform} = Transforms.Transform.create("compact_time", %{"time_period" => 23, "rubbish" => nil})
    assert status == :error
  end


  test "Failure - Create a transform struct with params when transform does not expect any params" do

    # Create a transform
    {status, transform} = Transforms.Transform.create("percentize", %{"time_period" => 23, "rubbish" => nil})
    assert status == :error
  end


  test "Figure out how pattern matching works with tuples" do
    Transforms.PatternMatching.create_tuple()
  end


  test "Success - Create and execute a transform series" do

    list_of_values1 = [1,1,1,0,1,2,2,3,3,5,5,1,0,0,3,0,2,2,2,2]
    # percentize = [20,20,20,0,20,40,40,60,60,100,100,20,0,0,60,0,40,40,40,40]
    # remove base noise = [0,0,0,0,0,6,6,26,26,66,66,0,0,0,26,0,6,6,6,6]
    # remove low percentages = [0,0,0,0,0,6,6,26,26,66,66,0,0,0,26,0,6,6,6,6]
    expected_result = [0,0,0,0,0,6,6,26,26,66,66,0,0,0,0,0,6,6,6,6]

    # Create the components for the transform series
    {_, metric} = Transforms.Metric.create("mem_avg", @list_of_keys1, list_of_values1)
    {_, transform1} = Transforms.Transform.create("percentize", %{})
    {_, transform2} = Transforms.Transform.create("remove_base_noise", %{})
    {_, transform3} = Transforms.Transform.create("remove_low_percentages", %{})
    {_, transform4} = Transforms.Transform.create("remove_spikes", %{})
    list_of_transforms = [transform1, transform2, transform3, transform4]
    date_from = ~D[2018-11-01]
    date_to = ~D[2018-11-30]

    # Create a transform series
    {status, transform_series} = Transforms.TransformSeries.create(metric, list_of_transforms, "group_id", "connection_id", "machine_name", date_from, date_to)
    assert status == :ok

    # Execute a series of transforms
    {status, result_metric} = Transforms.TransformSeries.execute(%{:series => transform_series})
    assert status == :ok
    assert result_metric.name == "mem_avg:percentize:remove_base_noise:remove_low_percentages:remove_spikes"
    assert result_metric.keys == @list_of_keys1
    assert result_metric.values == expected_result

    Logger.debug("Result_metric after transforms is: #{inspect result_metric}")

  end


  test "Success - Create and execute a transform series while overriding default params" do

    list_of_values1 = [1,1,1,0,1,2,0,3,3,5,5,1,0,0,3,0,2,2,2,2]
    # percentize = [20,20,20,0,20,40,0,60,60,100,100,20,0,0,60,0,40,40,40,40]
    # remove base noise = [4,4,4,0,4,24,0,44,44,84,84,4,0,0,44,0,24,24,24,24]
    # remove low percentages = [0,0,0,0,0,0,0,44,44,84,84,0,0,0,44,0,0,0,0]
    expected_result = [0,0,0,0,0,0,0,44,44,84,84,0,0,0,0,0,0,0,0,0]

    # Create the components for the transform series
    {_, metric} = Transforms.Metric.create("mem_avg", @list_of_keys1, list_of_values1)
    {_, transform1} = Transforms.Transform.create("percentize", %{})
    {_, transform2} = Transforms.Transform.create("remove_base_noise", %{"rolling_avg_length" => 5})
    {_, transform3} = Transforms.Transform.create("remove_low_percentages", %{"floor" => 25})
    {_, transform4} = Transforms.Transform.create("remove_spikes", %{"base_window_length" => 2, "spike_window_length" => 1})
    list_of_transforms = [transform1, transform2, transform3, transform4]
    date_from = ~D[2018-11-01]
    date_to = ~D[2018-11-30]


    # Create a transform series
    {status, transform_series} = Transforms.TransformSeries.create(metric, list_of_transforms, "group_id", "connection_id", "machine_name", date_from, date_to)
    assert status == :ok

    # Execute a series of transforms
    {status, result_metric} = Transforms.TransformSeries.execute(%{:series => transform_series})
    assert status == :ok
    assert result_metric.name == "mem_avg:percentize:remove_base_noise:remove_low_percentages:remove_spikes"
    assert result_metric.keys == @list_of_keys1
    assert result_metric.values == expected_result

    Logger.debug("Result_metric after transforms is: #{inspect result_metric}")

  end


  test "Success - Create and execute a list of transform series while overriding default params" do

    list_of_values1 = [1,1,1,0,1,2,0,3,3,5,5,1,0,0,3,0,2,2,2,2]
    list_of_values2 = [3,4,2,0,1,2,0,3,3,5,5,1,0,0,3,0,2,2,2,2]
    list_of_values3 = [4,4,4,0,1,2,0,3,3,5,5,1,0,0,3,0,2,2,2,2]
    # percentize = [20,20,20,0,20,40,0,60,60,100,100,20,0,0,60,0,40,40,40,40]
    # remove base noise = [4,4,4,0,4,24,0,44,44,84,84,4,0,0,44,0,24,24,24,24]
    # remove low percentages = [0,0,0,0,0,0,0,44,44,84,84,0,0,0,44,0,0,0,0]
    expected_result = [0,0,0,0,0,0,0,44,44,84,84,0,0,0,0,0,0,0,0,0]

    # Create the components for the transform series
    {_, metric1} = Transforms.Metric.create("mem_min", @list_of_keys1, list_of_values1)
    {_, metric2} = Transforms.Metric.create("mem_avg", @list_of_keys1, list_of_values2)
    {_, metric3} = Transforms.Metric.create("mem_max", @list_of_keys1, list_of_values3)
    {_, transform1} = Transforms.Transform.create("percentize", %{})
    {_, transform2} = Transforms.Transform.create("remove_base_noise", %{"rolling_avg_length" => 5})
    {_, transform3} = Transforms.Transform.create("remove_low_percentages", %{"floor" => 25})
    {_, transform4} = Transforms.Transform.create("remove_spikes", %{"base_window_length" => 2, "spike_window_length" => 1})
    list_of_transforms = [transform1, transform2, transform3, transform4]
    date_from = ~D[2018-11-01]
    date_to = ~D[2018-11-30]

    # Create three transform series
    {status, transform_series1} = Transforms.TransformSeries.create(metric1, list_of_transforms, "group_id", "connection_id", "machine_name", date_from, date_to)
    assert status == :ok
    {status, transform_series2} = Transforms.TransformSeries.create(metric2, list_of_transforms, "group_id", "connection_id", "machine_name", date_from, date_to)
    assert status == :ok
    {status, transform_series3} = Transforms.TransformSeries.create(metric3, list_of_transforms, "group_id", "connection_id", "machine_name", date_from, date_to)
    assert status == :ok
    list = [transform_series1, transform_series2, transform_series3]

    # Execute a series of transforms
#    {status, result_metric} = Transforms.TransformSeries.execute(%{:series, transform_series})
    {status, result_metric} = Transforms.TransformSeries.execute(%{:list => list})
    # assert status == :ok
    # assert result_metric.name == "mem_avg:percentize:remove_base_noise:remove_low_percentages:remove_spikes"
    # assert result_metric.keys == @list_of_keys1
    # assert result_metric.values == expected_result

    Logger.debug("Result_metric after transforms is: #{inspect result_metric}")

  end


end
