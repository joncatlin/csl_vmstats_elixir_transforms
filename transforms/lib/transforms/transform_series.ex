defmodule Transforms.TransformSeries do

  require Logger

  @enforce_keys [:metric, :transforms, :group_id, :connection_id, :machine_name, :date_from, :date_to]
  defstruct metric: nil,
    transforms: nil,
    group_id: nil,
    connection_id: nil,
    machine_name: nil,
    date_from: nil,
    date_to: nil

  #  @type dict(key, value) :: [{key, value}]
  @type metric :: Transforms.Metric.t()
  @type transforms :: [Transforms.Transform.t()]
  @type t() :: %__MODULE__{
    metric: metric,
    transforms: transforms,
    group_id: String.t(),
    connection_id: String.t(),
    machine_name: String.t(),
    date_from: Date.t(),
    date_to: Date.t()
  }

  @type list_of_transform_series :: [t()]

  # Create the trasform series struct
  def create(metric, transforms, group_id, connection_id, machine_name, date_from, date_to) do

    series = %Transforms.TransformSeries{metric: metric, transforms: transforms, group_id: group_id, connection_id: connection_id, machine_name: machine_name, date_from: date_from, date_to: date_to}
    {:ok,  series}
  end

  # Execute either a list of transform series or a single series
  def execute(something) do
    case something do
      %{series: series} ->
        new_metric = execute_series(series.metric, series.transforms)
        Logger.debug("In TransformSeries.execute, found series, new_metric=#{inspect new_metric}")
        {:ok, new_metric}
      %{list: list} ->
        result = list
        |> Enum.map(&(Task.async(fn ->
          {status, result_metric} = execute(%{:series => &1})
          result_metric
        end)))
        |> Enum.map(&Task.await/1)

        # Combine all of the results
        TBD

        Logger.debug("In TransformSeries.execute(list_of_transform_series), result=#{inspect result}")
        # {:ok,  new_metric}
    end
  end


  # def execute({:series, transform_series}) do
  #   new_metric = execute_series(transform_series.metric, transform_series.transforms)
  #   Logger.debug("In TransformSeries.execute, new_metric=#{inspect new_metric}")
  #   {:ok,  new_metric}
  # end


  # def execute({:list, list_of_transform_series}) do
  #   result = list_of_transform_series
  #   |> Enum.map(&(Task.async(fn -> execute(&1) end)))
  #   |> Enum.map(&Task.await/1)

  #   # Combine all of the results

  #   Logger.debug("In TransformSeries.execute(list_of_transform_series), result=#{inspect result}")
  #   # {:ok,  new_metric}
  # end


  # -------------- RECURSION -------------------
  # Recurively process the transforms
  defp execute_series(metric, []) do
    metric
  end

  defp execute_series(metric, [head | tail]) do
    {new_list_of_keys, new_list_of_values} = head.func.(metric.keys, metric.values, head.parameters)
    {status, metric} = Transforms.Metric.create(metric.name <> ":" <> head.name, new_list_of_keys, new_list_of_values)
    execute_series(metric, tail)
  end

end


