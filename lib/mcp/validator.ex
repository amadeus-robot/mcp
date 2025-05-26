defmodule MCPServer.Tools.Validator do
  @moduledoc """
  Validation utilities for tools
  """

  def validate_tool(module) do
    checks = [
      &validate_behavior/1,
      &validate_schema/1,
      &validate_handle_function/1
    ]

    Enum.reduce_while(checks, :ok, fn check, :ok ->
      case check.(module) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_behavior(module) do
    behaviours =
      module.module_info(:attributes)
      |> Keyword.get(:behaviour, [])

    if MCPServer.Tool in behaviours do
      :ok
    else
      {:error, "Module does not implement Tool behavior"}
    end
  end

  defp validate_schema(module) do
    try do
      schema = apply(module, :input_schema, [])
      # Add JSON schema validation here
      :ok
    rescue
      _ -> {:error, "Invalid input schema"}
    end
  end

  defp validate_handle_function(module) do
    if function_exported?(module, :handle, 1) do
      :ok
    else
      {:error, "handle/1 function not exported"}
    end
  end
end
