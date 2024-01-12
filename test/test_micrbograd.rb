# frozen_string_literal: true

require "test_helper"

class TestMicrbograd < Minitest::Test
  include Micrbograd

  def test_operations
    assert_equal(7, (Value.new(3) + Value.new(4)).data)
    assert_equal(12, (Value.new(3) * Value.new(4)).data)
    assert_equal(81, (Value.new(3)**4).data)
    assert_equal(-3, -Value.new(3).data)
    assert_equal(-1, (Value.new(3) - Value.new(4)).data)
    assert_equal(0.75, (Value.new(3) / Value.new(4)).data)
    assert_in_delta(0.00001, 0.761594, Value.new(1).tanh.data)

    a = Value.new(3)
    b = Value.new(1)
    c = Value.new(4)
    d = Value.new(1)
    e = Value.new(5)
    f = ((a + b) * (c - d)) / e
    assert_in_delta(2.4, f.data, 0.00001)
  end

  def test_backpropagate
    x1 = Value.new(2.0)
    x2 = Value.new(0.0)
    w1 = Value.new(-3.0)
    w2 = Value.new(1.0)
    b = Value.new(6.8813735870195432)
    x1w1 = x1 * w1
    x2w2 = x2 * w2
    x1w1x2w2 = x1w1 + x2w2
    n = x1w1x2w2 + b
    o = n.tanh
    o.backpropagate

    assert_in_delta(1.0, o.gradient, 0.0000001)
    assert_in_delta(0.5, n.gradient, 0.0000001)
    assert_in_delta(0.5, b.gradient, 0.0000001)
    assert_in_delta(0.5, x1w1x2w2.gradient, 0.0000001)
    assert_in_delta(0.5, x2w2.gradient, 0.0000001)
    assert_in_delta(0.5, x1w1.gradient, 0.0000001)
    assert_in_delta(0.0, w2.gradient, 0.0000001)
    assert_in_delta(0.5, x2.gradient, 0.0000001)
    assert_in_delta(1.0, w1.gradient, 0.0000001)
    assert_in_delta(-1.5, x1.gradient, 0.0000001)
  end

  def test_backpropagate_repeated
    a = Value.new(5.0)
    b = a + a
    b.backpropagate

    assert_in_delta(10.0, b.data, 0.000001)
    assert_in_delta(5.0, a.data, 0.000001)

    assert_in_delta(1.0, b.gradient, 0.000001)
    assert_in_delta(2.0, a.gradient, 0.000001)
  end
end
