# Simplifying Memory Management by Using Builtin's

Following on from my previous post regarding passing arrays between JavaScript
and WebAssembly, I have found out how to remove the need to call back into JavaSrcript

## Prerequisites

These examples have been tested with [nodejs v12.9.1](https://nodejs.org),
[clang 10.0.0](https://clang.llvm.org/),
and [wabt 1.0.16](https://github.com/WebAssembly/wabt) on Ubuntu 18.04.

I installed `clang` in `/opt/clang`, `wabt` in `/opt/wabt`, and I use
[nodenv](https://github.com/nodenv/nodenv) to manage my `nodejs` environment.

Update your path.

```bash
export PATH=/opt/clang/bin:/opt/wabt/bin:$PATH
```

## What was the problem?

In order to find the size of the memory and grow it, I was having to import
functions from JavaScript. I now find there are two built in functions that
do exactly what I want:

* __builtin_wasm_memory_size(0)
* __builtin_wasm_memory_grow(0, blocks)

This means my `growMoreMemory` function now looks like this.


```c
#define BLKSIZ 65536

static header_t* getMoreMemory(unsigned bytes_required)
{
  // We need to add the header to the bytes required.
  bytes_required += sizeof(header_t);

  // The memory gets delivered in blocks. Ensure we get enough.
  unsigned int blocks = bytes_required / BLKSIZ;
  if (blocks * BLKSIZ < bytes_required)
    blocks += 1;
  unsigned int start_of_new_memory = __builtin_wasm_memory_size(0) * BLKSIZ;

  if (__builtin_wasm_memory_grow(0, blocks) == -1)
  	return NULL;

  long end_of_new_memory = __builtin_wasm_memory_size(0) * BLKSIZ;

  // Create the block to insert.
  header_t* block_to_insert = (header_t *) start_of_new_memory;
  block_to_insert->value.size = end_of_new_memory - start_of_new_memory - sizeof(header_t);
  block_to_insert->value.next = NULL;

  // add to the free list
  freeMemory((void *) (block_to_insert + 1));

  return free_list;
}
```
