defmodule PoolProc.Worker do
  use GenServer

  @name __MODULE__
  @init_index 1

  def start_link(pool_name) do
    GenServer.start_link(@name, nil, name: pool_name)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:run, pool_name, fun}, _from, state) do
    Agent.update(PoolProc.Pool.get_name("#{pool_name}-settings"),
      fn map ->
        Map.update(map, pool_name, {get_pool_size(map[pool_name]), @init_index},
        fn t -> update_pool(t) end)
      end)

    #IO.inspect self()

    {:reply, fun.(), state};
  end

  def run(pool_name, fun) do
    index = Agent.get(PoolProc.Pool.get_name("#{pool_name}-settings"), &(&1))
      |> Map.get(pool_name)
      |> elem(1)

    GenServer.call(PoolProc.Pool.get_name("#{pool_name}-#{index}"), {:run, pool_name, fun})
  end

  defp update_pool(pool) do
    {pool_size, pool_index} = pool
    {pool_size, case pool_index do
                  ^pool_size -> @init_index
                  _ -> pool_index + @init_index
                end}
  end

  defp get_pool_size(pool_name) do
    pool_name |> elem(0)
  end
end
