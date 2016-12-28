defmodule PoolProcTest do
  use ExUnit.Case
  #doctest PoolProc

  test "create a pool" do
    PoolProc.Pool.create_pool "test_pool", [pool_size: 5]
    list = for _ <- 1..10, do: PoolProc.Worker.run "test_pool", fn -> 1 end

    assert 10 == Enum.sum(list)
  end

  test "create multiple pools" do
    PoolProc.Pool.create_pool "test_pool1", [pool_size: 5]
    list1 = for _ <- 1..10, do: PoolProc.Worker.run "test_pool", fn -> 1 end

    PoolProc.Pool.create_pool "test_pool2", [pool_size: 5]
    list2 = for _ <- 1..10, do: PoolProc.Worker.run "test_pool", fn -> 2 end

    assert 10 == Enum.sum(list1)
    assert 20 == Enum.sum(list2)
  end
end
