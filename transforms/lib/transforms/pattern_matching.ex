defmodule Transforms.PatternMatching do

  require Logger

  def create_tuple do

    my_tup = %{list: [1,2,3]}
    my_tup2 = %{:list => [1,2,3]}

    func1(my_tup2)
  end


  defp func1(tup) do
    case tup do
      {:list, list} -> Logger.debug("{:list, list} This works")
      %{list: list} -> Logger.debug("%{list: list} This works")
      # {:list => list} -> Logger.debug("{:list, list} This works")
      _ -> Logger.debug("Error no match")
    end
  end
  # This one does not work
  # defp func1({:list, list}) do
  #   Logger.debug("List: This works")
  # end


end
