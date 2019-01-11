defmodule TransformSeries do

  require Logger

  @enforce_keys [:metric, :transforms, :group_id, :connection_id, :machine, :date]
  defstruct metric: nil,
    transforms: nil,
    group_id: nil,
    connection_id: nil,
    machine: nil,
    date: nil

  #  @type dict(key, value) :: [{key, value}]
  @type metric :: Transforms.Metric.t()
  @type transforms :: [Transforms.Transform.t()]
  @type value :: float
  @type t() :: %__MODULE__{
    metric: metric,
    transforms: transforms,
    group_id: String.t(),
    connection_id: String.t(),
    machine: String.t(),
    date: Date.t()
  }

  # date_range
  # machine
  # transform series [transform, transform, transform, ...]




  def execute() do
    Logger.debug("In TransformSeries.execute")
  end

end


