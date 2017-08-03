defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  alias KV.Bucket

  setup do
    {:ok, bucket} = start_supervised({KV.Bucket, name: "test"})
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert Bucket.get(bucket, "milk") == nil

    Bucket.put(bucket, "milk", 3)
    assert Bucket.get(bucket, "milk") == 3
  end

  test "deletes values by key", %{bucket: bucket} do
    assert Bucket.delete(bucket, "soda") == nil

    Bucket.put(bucket, "soda", 4)
    assert Bucket.delete(bucket, "soda") == 4
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(Bucket, []).restart == :temporary
  end
end
