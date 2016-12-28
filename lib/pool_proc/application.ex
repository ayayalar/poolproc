defmodule PoolProc.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
   import Supervisor.Spec, warn: false

    children = [      
      supervisor(PoolProc.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: PoolProc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
