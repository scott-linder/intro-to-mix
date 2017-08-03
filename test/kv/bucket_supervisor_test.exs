defmodule KV.BucketSupervisorTest do
  use ExUnit.Case, async: true

  alias KV.BucketSupervisor

  test "starts bucket with name" do
    assert {:ok, bucket} = BucketSupervisor.start_bucket("bucket")
    refute Registry.lookup(KV.BucketRegistry, "bucket") == []
    assert [{^bucket, nil}] = Registry.lookup(KV.BucketRegistry, "bucket")
  end
end
