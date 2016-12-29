defmodule PoolProcTest do
  use ExUnit.Case
  #doctest PoolProc

  test "create a pool" do
    assert :ok == PoolProc.Pool.create_pool :test_pool, [pool_size: 5]
  end

  test "create a pool and exercise the workers concurrently" do
    PoolProc.Pool.create_pool :test_pool, [pool_size: 5]

    list = for i <- 1..10 do
      Task.async( fn ->
        PoolProc.Pool.get_worker(:test_pool)
        |> PoolProc.Pool.send_worker(fn -> 1 end)
      end)
    end

    results = for i <- list, do: Task.await(i)
    assert 10 == Enum.sum(results)
  end

  test "create multiple pools and exercise the workers" do
    PoolProc.Pool.create_pool :test_pool1, [pool_size: 5]
    PoolProc.Pool.create_pool :test_pool2, [pool_size: 5]

    list1 = for _ <- 1..10 do
      PoolProc.Pool.get_worker(:test_pool1)
        |> PoolProc.Pool.send_worker(fn -> 1 end)
    end

    list2 = for _ <- 1..10 do
      PoolProc.Pool.get_worker(:test_pool2)
        |> PoolProc.Pool.send_worker(fn -> 2 end)
    end

    assert 10 == Enum.sum(list1)
    assert 20 == Enum.sum(list2)
  end
end
