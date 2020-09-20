T = require('luaunit')
lsys = dofile('lsys.lua')

System = lsys.System

function test_empty_new()
  T.assertNotNil(System{})
end

function test_rule_init()
  local l = System{
    {'a', 'ab'},
    {'b', 'a'},
  }
  T.assertEquals(l:successor('a'), 'ab')
  T.assertEquals(l:successor('b'), 'a')
end

function test_rule_define()
  local l = System{}
  l:define_rule("a", "ab")
  l:define_rule("b", "a")
  T.assertEquals(l:successor('a'), 'ab')
  T.assertEquals(l:successor('b'), 'a')
end

function test_rule_define_validate()
  local l = System{}
  T.assertError(l.define_rule, l, 'ab', 'c')
end

function test_successor_identity_rule()
  local l = System{
    {'a', 'abc'}
  }
  T.assertEquals(l:successor('b'), 'b')
  T.assertEquals(l:successor('c'), 'c')
end

function test_successor_not_in_alphabet_error()
  local l = System{}
  T.assertError(l.successor, l, 'a')
end

function test_alphabet()
  local l = System{}
  -- empty case
  T.assertEquals(l:alphabet(), '')
  T.assertEquals(l:alphabet(true), {})
  -- full
  l:define_rule('a', 'ab')
  l:define_rule('b', 'cde')
  l:define_rule('c', 'ba')
  T.assertEquals(l:alphabet(), 'abcde')
  T.assertEquals(l:alphabet(true), {'a', 'b', 'c', 'd', 'e'})
end

function test_iterate_identity()
  local l = System{
    {'a', 'ab'}
  }
  T.assertEquals(l:iterate('b', 1), 'b')
end

function test_iterate_iter_single_rule()
  local l = System{
    {'a', 'ab'}
  }
  T.assertEquals(l:iterate('a', 1), 'ab')
  T.assertEquals(l:iterate('a', 2), 'abb')
  T.assertEquals(l:iterate('a', 3), 'abbb')
  -- expanded
  T.assertEquals(l:iterate('a', 2, true), {'a', 'b', 'b'})
end

function test_iterate_algae()
  -- algae example
  local l = System{
    {'a', 'ab'},
    {'b', 'a'},
  }
  T.assertEquals(l:iterate('a', 5), 'abaababaabaab')
end

function test_iterate_fractal()
  local l = System{
    {'1', '11'},
    {'0', '1[0]0'},
  }
  T.assertEquals(l:iterate('0', 3), '1111[11[1[0]0]1[0]0]11[1[0]0]1[0]0')
end

function test_iterate_implicit_n()
  local l = System{
    {'a', 'bc'},
  }
  T.assertEquals(l:iterate('a'), 'bc')
end

function test_iterate_compound_axiom()
  local l = System{
    {'a', 'bc'},
  }
  T.assertEquals(l:iterate('dac'), 'dbcc')
end

function test_to_axiom()
  -- empty
  T.assertEquals(lsys.to_axiom(), {})
  -- expand
  T.assertEquals(lsys.to_axiom('a'), {'a'})
  T.assertEquals(lsys.to_axiom('abc'), {'a', 'b', 'c'})
  -- identity
  T.assertEquals(lsys.to_axiom({}), {})
  T.assertEquals(lsys.to_axiom({'x', 'y'}), {'x', 'y'})
end

os.exit(T.LuaUnit.run())
