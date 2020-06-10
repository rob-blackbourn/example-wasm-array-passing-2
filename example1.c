extern void *allocateMemory(unsigned bytes_required);

__attribute__((used)) int* addArrays (int *array1, int* array2, int length)
{
  int* result = allocateMemory(length * sizeof(int));

  for (int i = 0; i < length; ++i) {
    result[i] = array1[i] + array2[i];
  }

  return result;
}

__attribute__((used)) unsigned int getMemorySize()
{
  // Returns the number of pages
  return __builtin_wasm_memory_size(0);
}

__attribute__((used)) long growMemory(unsigned int pages)
{
  // Returns the previous number of pages.
  return __builtin_wasm_memory_grow(0, pages);
}