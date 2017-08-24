# frozen_string_literal: true

require 'filterly/node'

module Filterly
  class NodeBuilder
    def self.build_equality_node(attr_name:, attr_value:)
      Filterly::Node.new(
        :expression,
        [
          :op_equal,
          Filterly::Node.new(:attr_name, [attr_name, nil, nil]),
          Filterly::Node.new(:attr_value, [attr_value, nil, nil])
        ]
      )
    end

    def self.build_not_equality_node(attr_name:, attr_value:)
      Filterly::Node.new(
        :expression,
        [
          :op_not_equal,
          Filterly::Node.new(:attr_name, [attr_name, nil, nil]),
          Filterly::Node.new(:attr_value, [attr_value, nil, nil])
        ]
      )
    end

    def self.build_exists_node(attr_name:, attr_value:)
      Filterly::Node.new(
        :expression,
        [
          :op_exists,
          Filterly::Node.new(:attr_name, [attr_name, nil, nil]),
          Filterly::Node.new(:attr_value, [attr_value, nil, nil])
        ]
      )
    end

    def self.build_array_values_node(attr_name:, array_of_values:)
      Filterly::Node.new(
        :expression,
        [
          :op_in,
          Filterly::Node.new(:attr_name, [attr_name, nil, nil]),
          attr_array(array_of_values)
        ]
      )
    end

    def self.build_and_statement_node(left:, right:)
      Filterly::Node.new(
        :statement,
        [
          :and,
          left,
          right
        ]
      )
    end

    def self.build_or_statement_node(left:, right:)
      Filterly::Node.new(
        :statement,
        [
          :or,
          left,
          right
        ]
      )
    end

    def self.build_custom_node(type:, args:)
      Filterly::Node.new(
        type,
        args
      )
    end

    # @api private
    def self.attr_array(array_of_values)
      Filterly::Node.new(:attr_array, [nil, ast_array(array_of_values), nil])
    end

    # @api private
    def self.ast_array(params)
      return if params.nil?
      return Filterly::Node.new(:attr_value, [params, nil, nil]) unless
        params.is_a?(Array)

      return if params.empty?

      Filterly::Node.new(:attr_value, attr_array_params(params))
    end

    # @api private
    def self.attr_array_params(array)
      [
        array[0],
        ast_array(array[1]),
        ast_array(array.drop(2))
      ]
    end
  end
end
