-- Copyright 2016 Stanford University
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

import "regent"

local c = regentlib.c

fspace k (r : region(int)) {
  s : region(int),
} where s <= r end

task f(m : region(int)) : int
where reads(m) do
  var o = 0
  for n in m do
    o += @n
  end
  return o
end

task g(a : region(int), b : k(a)) : int
where reads(a), writes(a) do
  var d = b.s
  var e = new(ptr(int, d))
  @e = 30
  return f(d)
end

task h() : int
  var t = region(ispace(ptr, 5), int)
  var tc = c.legion_coloring_create()
  c.legion_coloring_ensure_color(tc, 0)
  var u = partition(disjoint, t, tc)
  c.legion_coloring_destroy(tc)
  var v = u[0]
  var y = new(ptr(int, v))
  @y = 7
  var z = [k(t)]{ s = v }
  return g(t, z)
end

task main()
  regentlib.assert(h() == 37, "test failed")
end
regentlib.start(main)
