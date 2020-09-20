T = require('luaunit')
Lsys = dofile('lsys.lua')

function test_empty_new()
  T.assertNotNil(Lsys.new{})
end

function test_rule_init()
  local l = Lsys.new{
    {'a', 'ab'},
    {'b', 'a'},
  }
  T.assertEquals(l:successor('a'), 'ab')
  T.assertEquals(l:successor('b'), 'a')
end

function test_rule_define()
  local l = Lsys.new{}
  l:define_rule("a", "ab")
  l:define_rule("b", "a")
  T.assertEquals(l:successor('a'), 'ab')
  T.assertEquals(l:successor('b'), 'a')
end

function test_rule_define_validate()
  local l = Lsys.new{}
  T.assertError(l.define_rule, l, 'ab', 'c')
end

function test_successor_identity_rule()
  local l = Lsys.new{
    {'a', 'abc'}
  }
  T.assertEquals(l:successor('b'), 'b')
  T.assertEquals(l:successor('c'), 'c')
end

function test_successor_not_in_alphabet_error()
  local l = Lsys.new{}
  T.assertError(l.successor, l, 'a')
end

function test_alphabet()
  local l = Lsys.new{}
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

function test_generate_identity()
  local l = Lsys.new{
    {'a', 'ab'}
  }
  T.assertEquals(l:generate('b', 1), 'b')
end

function test_generate_iter_single_rule()
  local l = Lsys.new{
    {'a', 'ab'}
  }
  T.assertEquals(l:generate('a', 1), 'ab')
  T.assertEquals(l:generate('a', 2), 'abb')
  T.assertEquals(l:generate('a', 3), 'abbb')
  -- expanded
  T.assertEquals(l:generate('a', 2, true), {'a', 'b', 'b'})
end

function test_generate_algae()
  -- algae example
  local l = Lsys.new{
    {'a', 'ab'},
    {'b', 'a'},
  }
  T.assertEquals(l:generate('a', 5), 'abaababaabaab')
end

function test_generate_fractal()
  local l = Lsys.new{
    {'1', '11'},
    {'0', '1[0]0'},
  }
  T.assertEquals(l:generate('0', 3), '1111[11[1[0]0]1[0]0]11[1[0]0]1[0]0')
end

function test_generate_implicit_iteration()
  local l = Lsys.new{
    {'a', 'bc'},
  }
  T.assertEquals(l:generate('a'), 'bc')
end

function test_generate_compound_axiom()
  local l = Lsys.new{
    {'a', 'bc'},
  }
  T.assertEquals(l:generate('dac'), 'dbcc')
end

os.exit(T.LuaUnit.run())