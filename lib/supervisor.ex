defmodule PoolProc.Supervisor do
  use Supervisor

  @mod __MODULE__

  def start_link do
    Supervisor.start_link(@mod, [])
  end

  def init(_) do
    children = [supervisor(Registry, [:unique, Registry.Pool]),
      worker(PoolProc.Pool, [])]
    supervise(children, strategy: :one_for_one)
  end
end
