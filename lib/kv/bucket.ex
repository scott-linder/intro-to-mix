defmodule KV.Bucket do
  use Agent, restart: :temporary

  @doc """
  Starts a new bucket.
  """
  def start_link(name: name) do
    Agent.start_link(fn -> %{} end, name: {:via, Registry, {KV.BucketRegistry, name}})
  end

  @doc """
  Starts a new bucket by prepending `opts_rest` to `opts`.

  Required for the special case of `Supervisor.start_child/2` when the strategy
  is `:simple_one_for_one` and additional arguments are appended outside of
  `opts`.
  """
  def start_link(opts, opts_rest) do
    start_link(opts_rest ++ opts)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts a value into the `bucket` by `key`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes a value from the `bucket` by `key`.

  Returns the current value of `key`, if it exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
