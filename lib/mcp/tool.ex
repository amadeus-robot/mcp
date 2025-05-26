defmodule MCPServer.Tool do
  @moduledoc """
  Behavior for implementing tools in the JSON-RPC server.
  """
  
  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback input_schema() :: map()
  @callback handle(args :: map()) :: {:ok, map()} | {:error, term()}
  @callback category() :: atom()
  @callback enabled?() :: boolean()
  
  @optional_callbacks [category: 0, enabled?: 0]
  
  defmacro __using__(_opts) do
    quote do
      @behaviour MCPServer.Tool
      
      def category(), do: :general
      def enabled?(), do: true
      
      defoverridable category: 0, enabled?: 0
    end
  end
end
