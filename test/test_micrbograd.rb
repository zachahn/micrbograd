# frozen_string_literal: true

require "test_helper"

class TestMicrbograd < Minitest::Test
  include Micrbograd

  def test_methods
    assert_equal(7, (Value.new(3) + Value.new(4)).data)
    assert_equal(12, (Value.new(3) * Value.new(4)).data)
    assert_equal(81, (Value.new(3)**4).data)
    assert_equal(-3, -Value.new(3).data)
    assert_equal(-1, (Value.new(3) - Value.new(4)).data)
    assert_equal(0.75, (Value.new(3) / Value.new(4)).data)
    assert_in_delta(0.00005, 0.761594, Value.new(1).tanh.data)
  end
end
