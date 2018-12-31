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
end  
