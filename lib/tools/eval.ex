defmodule MCPServer.Tools.Elixir do
  use MCPServer.Tool
  
  def name(), do: "eval_elixir_snippet"
  def category(), do: :elixir
  
  def description() do
    "runs an snippet of elixir code and returns the results"
  end
  
  def input_schema() do
    %{
      "properties" => %{"code" => %{"type" => "string"}},
      "required" => ["code"],
      "type" => "object"
    }
  end
  
  def handle(%{"code" => code}) do
    res = SafeEvaluator.eval(code)
    {:ok, create_text_response(inspect(res, pretty: true))}
  end
  
  defp create_text_response(text) do
    %{
      "content" => [
        %{
          "text" => text,
          "type" => "text"
        }
      ]
    }
  end
end
