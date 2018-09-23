defmodule TransformsTest do
  use ExUnit.Case
  doctest Transforms

  test "define a Metric type" do
    metric1 = %Transforms.Metric{name: "mem_max", values: %{"34" => 34.56}}
    IO.puts "The mtric is defined as #{inspect metric1}"
    metric2 = %Transforms.Metric{name: "mem_max", values: "The little brown fox"}
    IO.puts "The mtric is defined as #{inspect metric2}"
    metric3 = %Transforms.Metric{name: "mem_max", values: "frog"}
    IO.puts "The mtric is defined as #{inspect metric3}"
  end

  test "define a TransformSeries" do
    
  end
end
