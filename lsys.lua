--- L-system
--
-- Ref:
--   https://en.wikipedia.org/wiki/L-system
--
-- @module lsys
--

--
-- utilities
--

local function ichars(str)
  return str:gmatch('.')
end

local function str_explode(str)
  local t = {}
  for c in ichars(str) do
    table.insert(t, c)
  end
  return t
end

local function table_extend(t, e)
  for _, v in ipairs(e) do
    table.insert(t, v)
  end
end

---
--- Lsys
---

local Lsys = {}
Lsys.__index = Lsys

--- Create a L-system object.
--
-- A rule is a table of two strings:
--  1: predecessor - a the single character
--  2: successor - one or more characters to replace
--                 predecessor with.
--
-- @tparam table rules Zero or more rules
--
-- @treturn Lsys instance.
function Lsys.new(rules)
  local this = setmetatable({}, Lsys)
  this._rules = {}
  this._alphabet = {}
  for i, r in ipairs(rules) do
    this:define_rule(r[1], r[2])
  end
  return this
end

-- Define a rule
--
-- @tparam string predecessor
-- @tparam string sucessor
function Lsys:define_rule(predecessor, successor)
  -- validate
  if #predecessor ~= 1 then
    error('predecessor must be a single character string')
  end

  -- register rule if not dup
  local successor = str_explode(successor)
  self._rules[predecessor] = successor

  -- add to alphabet
  self._alphabet[predecessor] = true
  for _, c in ipairs(successor) do
    self._alphabet[c] = true
  end
end

-- Returns the set of characters present within the rules
-- @tparam boolean expanded Return table instead of string
function Lsys:alphabet(expanded)
  local t = {}
  for k, v in pairs(self._alphabet) do
    table.insert(t, k)
  end
  table.sort(t)
  if expanded then return t end
  return table.concat(t)
end

-- Returns the successor for the given predecessor
--
-- If predecessor is not in the alphabet of the currently defined rules
-- an error will be signaled
--
-- For predecessors with no defined successor the identity rule applies
--
-- @tparam string predecessor
-- @tparam boolean expanded Return table instead of string
function Lsys:successor(predecessor, expanded)
  local r = self._rules[predecessor]
  if not r and self._alphabet[predecessor] then
    r = { predecessor }
  end

  if not r then
    error("predecessor '" .. predecessor .. "' is not in alphabet")
  end

  if expanded then return r end
  return table.concat(r, '')
end

-- Generate by iteratively applying rules to axiom
--
-- Axiom is a string of one or more characters from the alphabet.
--
-- @tparam string axiom Starting state
-- @tparam number n Iterations, defaults to 1
-- @tparam boolean expanded Return table instead of string
function Lsys:generate(axiom, n, expanded)
  local n = n or 1

  local v = nil
  if #axiom > 1 then
    v = str_explode(axiom)
  else
    v = { axiom }
  end

  for i = 1, n do v = self:apply(v) end

  if not expanded then
    return table.concat(v, '')
  end
  return v
end

-- Apply one generation of substitution
--
-- Note: this method does not validate symbols are from the alphabet.
--
-- @tparam table at Axiom table (symbols from the alphabet)
-- @treturn table
function Lsys:apply(at)
  local v = {}
  for _, c in ipairs(at) do
    local r = self._rules[c]
    table_extend(v, r or { c })
  end
  return v
end

return Lsys

