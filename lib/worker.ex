defmodule PoolProc.Worker do
  use GenServer

  @name __MODULE__

  def start_link(pool_name) do
    GenServer.start_link(@name, nil, name: pool_name)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:run, fun}, _from, state) do
    IO.puts "Executing...#{inspect self()}"

    {:reply, fun.() , state};
  end
end
