defmodule Transforms.Metric do

  @enforce_keys [:name, :values]
  defstruct name: nil,
            values: nil

#  @type dict(key, value) :: [{key, value}]
  @type key :: integer
  @type value :: float
  @type map_of_values :: {key, value}
  @type t() :: %__MODULE__{
          name: String.t(),
          values: map_of_values
#          values: Map.t(key, value)
#          values: Map.t(Integer.t(), Float.t())
#          values: Map.t(Transforms.Value.t())
        }
end  
