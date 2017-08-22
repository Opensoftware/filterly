# frozen_string_literal: true

require 'ast/sexp'

module Filterly
  class Tree
    attr_reader :ast_node

    def initialize(ast_node)
      @ast_node = ast_node
    end

    def extend_ast(node_attr_name, new_node, stmt_type)
      return if ast_node.nil?
      if ast_node.attr_name_equal?(node_attr_name)
        create_node(
          :statement,
          [
            stmt_type,
            new_node,
            ast_node
          ]
        )
      else
        recreate_node(node_attr_name, new_node, stmt_type)
      end
    end

    def recreate_node(node_attr_name, new_node, stmt_type)
      create_node(
        ast_node.type,
        [
          ast_node.value,
          self.class.new(ast_node.left).extend_ast(node_attr_name, new_node, stmt_type),
          self.class.new(ast_node.right).extend_ast(node_attr_name, new_node, stmt_type)
        ]
      )
    end

    def to_ast
      ast_node
    end

    def to_s
      ast_node.to_s
    end

    # @api private
    def create_node(*args)
      Filterly::Node.new(*args)
    end
  end
end
