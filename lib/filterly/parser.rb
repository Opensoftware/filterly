# frozen_string_literal: true

require 'ast/sexp'
require 'filterly/node_builder'

module Filterly
  class Parser
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def filters_to_ast
      builder.build_custom_node(
        type: :root,
        args: [
          :filters,
          to_ast,
          nil
        ]
      )
    end

    # @api private
    def to_ast
      if params.is_a?(Hash) && !params.empty?
        hash_to_ast
      elsif params.is_a?(Array) && !params.empty?
        array_to_ast
      end
    end

    # @api private
    def hash_to_ast
      left = params.shift
      right = params
      if right.empty?
        self.class.new(left).to_ast
      else
        builder.build_and_statement_node(
          left: self.class.new(left).to_ast,
          right: self.class.new(right).to_ast
        )
      end
    end

    # @api private
    def array_to_ast
      if params[1].is_a?(Array)
        ast_op_in
      else
        ast_op_equal
      end
    end

    # @api private
    def ast_op_equal
      builder.build_equality_node(attr_name: params[0], attr_value: params[1])
    end

    # @api private
    def ast_op_in
      builder.build_array_values_node(
        attr_name: params[0],
        array_of_values: params[1]
      )
    end

    # @api private
    def builder
      Filterly::NodeBuilder
    end
  end
end
