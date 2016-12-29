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
    create_pool_settings(pool_name, pool_size)

    for i <- 1..pool_size do
      PoolProc.Worker.start_link(get_name("#{pool_name}-#{i}"))
    end

    {:reply, :ok, state}
  end

  def handle_call({:worker, pool_name}, _from, state) do
    %{^pool_name => {_, index}} = get_pool_settings(pool_name)
    update_pool_settings(get_name("#{pool_name}-settings"), pool_name)

    {:reply, get_name("#{pool_name}-#{index}"), state}
  end

  def create_pool(pool_name, opts) do
    {:ok, pool_size} = Keyword.fetch(opts, :pool_size)
    GenServer.call(@name, {:pool, pool_name, pool_size})
  end

  def get_worker(pool_name) do
    GenServer.call(@name, {:worker, pool_name})
  end

  def send_worker(worker, fun) do
    GenServer.call(worker, {:run, fun})
  end

  defp get_name(pool_name) do
    {:via, Registry, {Registry.Pool, pool_name}}
  end

  defp get_pool_settings(pool_name) do
    Agent.get(get_name("#{pool_name}-settings"), &(&1))
  end

  defp update_pool_settings(pool_settings, pool_name) do
    Agent.update(pool_settings,
      fn map ->
        Map.update(map, pool_name, {get_pool_size(map[pool_name]), @init_index},
        fn settings -> update_pool(settings) end)
      end)
  end

  defp create_pool_settings(name, size) do
    Agent.start_link(fn -> %{name => {size, @init_index}} end,
      name: get_name("#{name}-settings"))
  end

  defp get_pool_size(pool_name) do
    pool_name |> elem(0)
  end

  defp update_pool(pool) do
    {pool_size, pool_index} = pool
    {pool_size, get_index(pool_size, pool_index)}
  end

  defp get_index(pool_size, pool_index) do
    case pool_index do
      ^pool_size -> @init_index
      _ -> pool_index + @init_index
    end
  end
end
