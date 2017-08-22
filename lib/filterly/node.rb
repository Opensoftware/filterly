# frozen_string_literal: true

require 'ast/sexp'

module Filterly
  class Node < AST::Node
    attr_reader :value, :left, :right

    # freezes after init
    def initialize(type, children = [], properties = {})
      @value = children[0]
      @left = children[1]
      @right = children[2]

      super(type, children, properties)
    end

    def attr_name_equal?(node_attr_name)
      node_with_attr_name? && left.children.first == node_attr_name
    end

    def node_with_attr_name?
      return false if leaf?
      left.type == :attr_name
    end

    def leaf?
      left.nil? && right.nil?
    end

    def to_a
      [type, [value, left.to_a, right.to_a]]
    end
  end
end
