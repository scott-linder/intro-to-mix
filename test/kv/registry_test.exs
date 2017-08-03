defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  alias KV.{Registry, Bucket}

  setup do
    {:ok, registry} = start_supervised KV.Registry
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert Registry.lookup(registry, "shopping") == :error

    Registry.create(registry, "shopping")
    assert {:ok, bucket} = Registry.lookup(registry, "shopping")

    Bucket.put(bucket, "milk", 1)
    assert Bucket.get(bucket, "milk") == 1
  end

  test "removes bucket on exit", %{registry: registry} do
    Registry.create(registry, "shopping")
    {:ok, bucket} = Registry.lookup(registry, "shopping")
    Agent.stop(bucket) # simulate a graceful exit
    assert Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Registry.create(registry, "shopping")
    {:ok, bucket} = Registry.lookup(registry, "shopping")

    Agent.stop(bucket, :shutdown) # simulate a crash
    assert Registry.lookup(registry, "shopping") == :error
  end
end
