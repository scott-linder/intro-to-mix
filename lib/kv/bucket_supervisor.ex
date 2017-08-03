defmodule KV.BucketSupervisor do
  use Supervisor

  @name KV.BucketSupervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_bucket(name) do
    Supervisor.start_child(@name, [[name: name]])
  end

  def init(:ok) do
    children = [
      KV.Bucket
    ]
    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
