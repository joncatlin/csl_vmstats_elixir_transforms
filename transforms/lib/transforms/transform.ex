defmodule Transforms.Transform do

  @enforce_keys [:name, :parameters]
  defstruct name: nil,
            func: nil,
            parameters: %{}

  @type key :: String.t()
  @type value :: String.t()
  @type map_of_values :: {key, value}
  @type t() :: %__MODULE__{
    name: String.t(),
    func: String.t(),
    parameters: map_of_values
  }

  # Create a transform with name only
  def create(name) do
    create(name, %{})
  end


  # Create a transform and return it
  def create(name, parameters) do

    # The list of valid transforms
    valid_transforms = %{
      "combine" => %{:func => &Transforms.CombineTransform.transform/5, :params => []},
      "compact_time" => %{:func => &Transforms.CompactTimeTransform.transform/3, :params => ["time_period"]},
      "percentize" => %{:func => &Transforms.PercentizeTransform.transform/3, :params => []},
      "remove_base_noise" => %{:func => &Transforms.RemoveBaseNoiseTransform.transform/3, :params => ["rolling_avg_length"]},
      "remove_low_percentages" => %{:func => &Transforms.RemoveLowPercentagesTransform.transform/3, :params => ["floor"]},
      "remove_spikes" => %{:func => &Transforms.RemoveSpikesTransform.transform/3, :params => ["base_window_length", "spike_window_length"]}
    }

    # ensure the name is valid
    case Map.has_key?(valid_transforms, name) do
      true ->
        # Get the params and check that the parameters passed match the list
        # of valid param names
        %{:func => func, :params => valid_param_names} = valid_transforms[name]

#        Enum.all?(valid_param_names, &Map.has_key?(map, &1))

        case are_valid(valid_param_names, Map.keys(parameters)) do
          true -> {:ok, %Transforms.Transform{name: name, func: func, parameters: parameters}}
          _ -> {:error, "One or more of the parameters in the list is invalid. Valid parameter names are: #{inspect valid_param_names}"}
        end
      _ -> {:error, "No transform called #{inspect name}"}
      end
  end

  # Check the parameters are valid
  defp are_valid([], []) do
    true
  end

  defp are_valid(valid_param_names, []) do
    true
  end

  defp are_valid([], _) do
    false
  end

  defp are_valid(valid_param_names, [head | tail]) do
    Enum.member?(valid_param_names, head) and are_valid(valid_param_names, tail)
  end

end
