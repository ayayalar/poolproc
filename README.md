# PoolProc

**Description**
Pool of workers to run tasks concurrently to one another

## Usage

```elixir
# create a pool with 5 workers
PoolProc.Pool.create_pool "test_pool", [pool_size: 5]

# send fn to workers.
list = for _ <- 1..10, do: PoolProc.Worker.run "test_pool", fn -> 1 end
```
