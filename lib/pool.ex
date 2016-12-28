defmodule PoolProc.Pool do
  use GenServer

  @name __MODULE__
  @init_index 1

  def start_link() do
    GenServer.start_link(@name, nil, name: @name)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:pool, pool_name, pool_size}, _from, state) do
    Agent.start_link(fn -> %{} end, name: get_name("#{pool_name}-settings"))
    for i <- 1..pool_size do
      PoolProc.Worker.start_link(get_name("#{pool_name}-#{i}"))
    end

    Agent.update(get_name("#{pool_name}-settings"),
      &(Map.put(&1, pool_name, {pool_size, @init_index})))

    {:reply, :ok, state}
  end

  def create_pool(pool_name, opts) do
    {:ok, pool_size} = Keyword.fetch(opts, :pool_size)
    GenServer.call(@name, {:pool, pool_name, pool_size})
  end

  def get_name(pool_name) do
    {:via, Registry, {Registry.Pool, pool_name}}
  end
end
