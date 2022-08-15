function find_index(array, func)
  for i = 1, #array do
    local found = func(array[i])
    if (found) return i
  end

  return nil
end