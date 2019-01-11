defmodule Transforms.Metric do

  @enforce_keys [:name, :keys, :values]
  defstruct name: nil,
            keys: nil,
            values: nil

#  @type dict(key, value) :: [{key, value}]

  # @type key :: integer
  # @type value :: float
  @type t() :: %__MODULE__{
          name: String.t(),
          keys: List.t(integer),
          values: List.t(float)
#          values: Map.t(key, value)
#          values: Map.t(Integer.t(), Float.t())
#          values: Map.t(Transforms.Value.t())
        }
end
