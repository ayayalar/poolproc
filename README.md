# PoolProc

**Description**
Create pool of workers based on the `Registry` module introduced in elixir v1.4

## Usage

```elixir
# create a pool with 5 workers
PoolProc.Pool.create_pool :test_pool, [pool_size: 5]

# get a worker from the pool send fn

PoolProc.Pool.get_worker(:test_pool)
  |> PoolProc.Pool.send_worker(fn -> 1 end)
```
