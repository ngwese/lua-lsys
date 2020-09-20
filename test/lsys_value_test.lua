T = require('luaunit')
lsys = dofile('lsys.lua')

function test_trivial()
  t = {'a', 'b', 'c'}
  T.assertEquals(lsys.value(t), t)
end

function test_empty()
  t = {}
  T.assertEquals(lsys.value(t), t)
end

function test_tostring()
  T.assertEquals(tostring(lsys.value({})), '')
  T.assertEquals(tostring(lsys.value({'a', 'b'})), 'ab')
end

function test_from()
  T.assertEquals(lsys.value_from({}), {})
  T.assertEquals(lsys.value_from(123), {'1', '2', '3'})
  T.assertEquals(lsys.value_from(''), {})
  T.assertEquals(lsys.value_from('xr'), {'x', 'r'})
end

function test_from_error_on_bad_type()
  T.assertError(lsys.value_from, true)
end

os.exit(T.LuaUnit.run())
