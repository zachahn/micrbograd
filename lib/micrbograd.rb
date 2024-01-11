# frozen_string_literal: true

module Micrbograd
  class Value
    def initialize(data, children: [], operation: nil)
      @data = data
      @children = children
      @operation = operation
      @grad = 0
    end

    attr_reader :data, :children, :operation, :grad
    private :children, :operation

    def +(other)
      Value.new(data + other.data, children: [self, other], operation: :+)
    end

    def *(other)
      Value.new(data * other.data, children: [self, other], operation: :*)
    end

    def **(other)
      raise TypeError, "Value `#{data}' Only accepts type `Numeric'. Got #{other}" unless other.is_a?(Numeric)
      Value.new(data**other, children: [self], operation: :**)
    end

    def tanh
      Value.new(Math.tanh(data), children: [self], operation: :tanh)
    end

    def -@
      other = Value.new(-1)
      self * other
    end

    def -(other)
      self + -other
    end

    def /(other)
      self * (other**-1)
    end

    def to_s
      "#<Micrbograd::Value @data=#{data}>"
    end
  end
end
