# frozen_string_literal: true

module Micrbograd
  class Value
    def self.random
      new(Kernel.rand * [1, -1].sample)
    end

    def self.with(*args)
      args.map { |arg| new(arg) }
    end

    def initialize(data, children: [], operation: nil)
      @data = data
      @children = children
      @operation = operation
      @gradient = 0.0
    end

    attr_accessor :data
    attr_accessor :gradient
    attr_reader :children, :operation

    def +(other)
      Value.new(data + other.data, children: [self, other], operation: :+)
    end

    def *(other)
      Value.new(data * other.data, children: [self, other], operation: :*)
    end

    def **(other)
      raise TypeError, "Value `#{data}' Only accepts type `Numeric'. Got #{other}" unless other.is_a?(Numeric)
      Value.new(data**other, children: [self], operation: [:**, other])
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

    def zero_gradient
      self.gradient = 0.0
    end

    protected def backpropagate_local
      case operation
      in :+
        a, b = children
        a.gradient += gradient
        b.gradient += gradient
      in :*
        a, b = children
        a.gradient += b.data * gradient
        b.gradient += a.data * gradient
      in [:**, num]
        a, = children
        a.gradient += num * (a.data**(num - 1)) * gradient
      in :tanh
        a, = children
        a.gradient += (1 - (Math.tanh(a.data)**2)) * gradient
      in nil
      else
        raise "Unhandled operation: `#{operation.inspect}`"
      end
      nil
    end

    def backpropagate
      topological_ordering = []
      seen = {}
      tsort = lambda do |node|
        if !seen[node]
          seen[node] = true
          node.children.each do |child|
            tsort.call(child)
          end
          topological_ordering.push(node)
        end
      end
      tsort.call(self)

      self.gradient = 1.0
      topological_ordering.reverse_each { _1.backpropagate_local }
    end

    def to_s
      "#<Micrbograd::Value @data=#{data}>"
    end
  end

  module Shared
    def zero_gradients
      parameters.map { |parameter| parameter.zero_gradient }
    end
  end

  class Neuron
    include Shared

    def initialize(number_of_inputs)
      @weights = number_of_inputs.times.map { Value.random }
      @bias = Value.random
    end

    attr_accessor :weights, :bias

    def call(xs)
      raise "Mismatching sizes #{@weights.size}, #{xs.size}" unless @weights.size == xs.size
      actuality = @weights.zip(xs).map { |w, x| w * x }.reduce(:+) + @bias
      actuality.tanh
    end

    def parameters
      weights + [bias]
    end
  end

  class Layer
    include Shared

    def initialize(number_of_inputs, number_of_neurons)
      @neurons = number_of_neurons.times.map { Neuron.new(number_of_inputs) }
    end

    attr_accessor :neurons

    def call(xs)
      result = neurons.map { |neuron| neuron.call(xs) }
      if result.size == 1
        result.first
      else
        result
      end
    end

    def parameters
      neurons.flat_map do |neuron|
        neuron.parameters
      end
    end
  end

  class MultiLayerPerceptron
    include Shared

    def initialize(number_of_inputs, list_of_number_of_neurons)
      sz = [number_of_inputs] + list_of_number_of_neurons
      @layers = sz.each_cons(2).map do |a, b|
        Layer.new(a, b)
      end
    end

    attr_accessor :layers

    def call(xs)
      layers.each do |layer|
        xs = layer.call(xs)
      end
      xs
    end

    def parameters
      layers.flat_map do |layer|
        layer.parameters
      end
    end
  end

  MLP = MultiLayerPerceptron
end
