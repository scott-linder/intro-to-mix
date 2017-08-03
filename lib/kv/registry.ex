defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Look up the bucket pid for `name` stored in `registry`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(registry, name) do
    GenServer.call(registry, {:lookup, name})
  end

  @doc """
  Ensure there is a bucket associated with the given `name` in `registry`.
  """
  def create(registry, name) do
    GenServer.cast(registry, {:create, name})
  end

  @doc """
  Stop the registry.
  """
  def stop(registry) do
    GenServer.stop(registry)
  end

  ## Server Callbacks

  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = KV.BucketSupervisor.start_bucket()
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
