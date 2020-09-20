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

local function to_axiom(thing)
  if type(thing) == 'string' then
    return str_explode(thing)
  end
  return value(thing or {})
end

local function table_extend(t, e)
  for _, v in ipairs(e) do
    table.insert(t, v)
  end
end

--
-- Value
--

local Value = {}
Value.__index = Value

function value(thing)
  setmetatable(thing, Value)
  return thing
end

function value_from(thing)
  if type(thing) == 'string' then
    return value(str_explode(thing))
  elseif type(thing) == 'number' then
    return value(str_explode(tostring(thing)))
  elseif type(thing) == 'table' then
    return value(thing)
  end

  error("Cannot convert value of type: " .. type(thing))
end

function Value:__tostring()
  return table.concat(self)
end

--
-- Selector
--

local Selector = {}
Selector.__index = Selector

function Selector.new(items)
  local self = setmetatable({}, Selector)
  self._choices = {}
  for _, i in ipairs(items or {}) do
    local v = i
    local w = 1
    if type(i) == 'table' and i.weight then
      v = i[1]
      w = i.weight or w
    end
    self:add(v, w)
  end
  return self
end

function Selector:add(thing, weight)
  local weight = weight or 1
  local total = weight
  -- (re)normalize weights
  for _, choice in ipairs(self._choices) do
    total = total + choice.weight
  end
  -- update existing
  local acc = 0
  for _, choice in ipairs(self._choices) do
    acc = acc + (choice.weight / total)
    choice[1] = acc
  end
  -- add new
  acc = acc + (weight / total)
  table.insert(self._choices, {acc, thing, weight = weight})
end

function Selector:choices()
  return self._choices
end

function Selector:__call(normalized_weight)
  local w = normalized_weight or 0 -- always choose first
  local last = nil
  for _, c in ipairs(self._choices) do
    if w < c[1] then return c[2] end
    last = c
  end
  -- failsafe, choose last
  return (last and last[2]) or nil
end

---
--- System
---

local System = {}
System.__index = System

--- Create a stochastic L-system object.
--
-- A rule is a table of two strings, plus properties:
--  1: predecessor - a the single character
--  2: successor   - one or more characters to replace
--                   predecessor with
--  weight: number - rules with the same predecessor are
--                   chosen based on a normalization of their
--                   weights. The default weight is 1
--
-- @tparam table rules Zero or more rules
--
-- @treturn System instance.
function System.new(rules)
  local this = setmetatable({}, System)
  this._rules = {}
  this._alphabet = {}
  for i, r in ipairs(rules or {}) do
    this:define_rule(r[1], r[2])
  end
  return this
end

-- Define a rule
--
-- @tparam string predecessor
-- @tparam string sucessor
function System:define_rule(predecessor, successor, weight)
  -- validate
  if #predecessor ~= 1 then
    error('predecessor must be a single character string')
  end

  -- register rule if not dup
  local successor = value(str_explode(successor))
  local selector = self._rules[predecessor]
  if selector == nil then
    selector = Selector.new()
    self._rules[predecessor] = selector
  end
  selector:add(successor, weight)

  -- add to alphabet
  self._alphabet[predecessor] = true
  for _, c in ipairs(successor) do
    self._alphabet[c] = true
  end
end

-- Returns the set of characters present within the rules
-- @treturn Value
function System:alphabet()
  local t = {}
  for k, v in pairs(self._alphabet) do
    table.insert(t, k)
  end
  table.sort(t)
  return value(t)
end

-- Returns the successor for the given predecessor
--
-- If predecessor is not in the alphabet of the currently defined rules
-- an error will be signaled
--
-- For predecessors with no defined successor the identity rule applies
--
-- @tparam string predecessor
-- @treturn Value
function System:successor(predecessor)
  local r = self._rules[predecessor]
  if not r and self._alphabet[predecessor] then
    r = Selector.new{value_from(predecessor)} -- identity rule
  end

  if not r then
    error("predecessor '" .. predecessor .. "' is not in alphabet")
  end

  return r
end

-- Iteratively apply rules to axiom
--
-- Axiom is a string of one or more characters from the alphabet.
--
-- @tparam string|Value axiom Starting state
-- @tparam number n Iterations, defaults to 1
-- @treturn Value
function System:iterate(axiom, n)
  local n = n or 1
  local v = value_from(axiom)
  for i = 1, n do v = self:apply(v) end
  return v
end

-- Apply one generation of substitution
--
-- Note: this method does not validate symbols are from the alphabet.
--
-- @tparam table at Axiom table (symbols from the alphabet)
-- @treturn Value
function System:apply(at)
  local v = value({})
  for _, c in ipairs(at) do
    local selector = self._rules[c]
    local r = selector and selector()
    table_extend(v, r or { c })
  end
  return v
end

return {
  System = System.new,
  Selector = Selector.new,
  to_axiom = to_axiom,
  value = value,
  value_from = value_from,
}

