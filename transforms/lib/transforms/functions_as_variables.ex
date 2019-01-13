defmodule Transforms.FunctionsAsVariables do

  require Logger

  def create_list do

    varfunc1 = &func1/1
    IO.puts("Hello jon")
    varfunc1.([1,2,5,8,0])

    jonmap = %{func: &func1/1}
  end


  defp func1(list) do
    Enum.map(list, fn x -> Logger.debug("#{inspect x},") end)
  end

  defp func2(list) do

  end
end
