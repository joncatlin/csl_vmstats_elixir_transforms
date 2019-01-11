defmodule Transforms.Transform do

  @enforce_keys [:name, :parameters]
  defstruct name: nil,
            parameters: %{}

  @type key :: String.t()
  @type value :: String.t()
  @type map_of_values :: {key, value}
  @type t() :: %__MODULE__{
          name: String.t(),
          parameters: map_of_values
        }

  # The list of valid transforms
  valid_transforms = {
    "combine" => [],
    "compact_time" => ["time_period"],
    "percentize" => [],
    "remove_base_noise" => ["rolling_avg_length"],
    "remove_low_percentages" => ["floor"],
    "remove_spikes" => ["base_window_length", "spike_window_length"]
  }



  # Create a transform and return it
  def create(name, parameters) do

    # ensure the name is valid
    return = cond Map.has_key?(valid_transforms, name) do
      false -> {error: "No transform called #{inspect name}"}
      true ->
        # Get the params and check that the parameters passed match
        params = valid_transforms[name]

    end
    # ensure the paramters for the named transform are valid
    {ok:, %Transforms.Transform{name: name, parameters: parameters}}
  end

  # Check the parameters are valid
  defp are_vlaid([]) do
    true
  end

  defp are_valid([head | tail]) do
    cond do

    end
  end

end
