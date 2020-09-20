T = require('luaunit')
lsys = dofile('lsys.lua')

function test_selector_empty_init()
  local s = lsys.Selector()
  T.assertEquals(s:choices(), {})
  T.assertIsNil(s(), nil)
end

function test_selector_single_init()
  local s = lsys.Selector{ 'a' }
  T.assertEquals(s:choices(), {{1, 'a', weight = 1}})
  T.assertEquals(s(), 'a')
end

function test_selector_multi_init_equal_weight()
  local s = lsys.Selector{ 'a', 'b', 'c' }
  T.assertEquals(s(0), 'a')
  T.assertEquals(s(0.3), 'a')
  T.assertEquals(s(0.34), 'b')
  T.assertEquals(s(0.8), 'c')
end

function test_call_outside_normalized_range()
  local s = lsys.Selector{ 'a', 'z' }
  T.assertEquals(s(-0.5), 'a')
  T.assertEquals(s(1.2), 'z')
end

function test_add_equal_weight()
  local s = lsys.Selector{ 'a', 'b' }
  T.assertEquals(s(0.9), 'b')
  s:add('foo')
  T.assertEquals(s(0.9), 'foo')
  T.assertEquals(s(0.5), 'b')
end

os.exit(T.LuaUnit.run())
