defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      KV.BucketSupervisor,
      {Registry, keys: :unique, name: KV.BucketRegistry},
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
