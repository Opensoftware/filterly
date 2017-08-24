# frozen_string_literal: true

require 'ast/sexp'

module Filterly
  class Tree
    attr_reader :ast_node

    def initialize(ast_node)
      @ast_node = ast_node
    end

    def self.new(ast_node)
      ensure_ast_node!(ast_node)

      super(ast_node)
    end

    def extend_ast(node_attr_name, new_node, stmt_type)
      TreeTraverser.new(ast_node).extend_ast(node_attr_name, new_node, stmt_type)
    end

    def prepend_ast(new_node, stmt_type)
      ensure_ast_root!

      TreeTraverser.new(ast_node).prepend_ast(new_node, stmt_type)
    end

    def to_ast
      ast_node
    end

    def to_s
      ast_node.to_s
    end

    # @apir private
    def ensure_ast_root!
      raise 'Not a tree root!' if ast_node.type != :root
    end

    # @api private
    def self.ensure_ast_node!(ast_node)
      raise 'Not a Filterfly:Node!' if ast_node.nil? || !ast_node.is_a?(Filterly::Node)
    end

    class TreeTraverser
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
            self.class
              .new(ast_node.left)
              .extend_ast(node_attr_name, new_node, stmt_type),
            self.class
              .new(ast_node.right)
              .extend_ast(node_attr_name, new_node, stmt_type)
          ]
        )
      end

      def prepend_ast(new_node, stmt_type)
        create_node(
          ast_node.type,
          [
            ast_node.value,
            create_node(
              :statement,
              [stmt_type, new_node, ast_node.left]
            ),
            nil
          ]
        )
      end

      # @api private
      def create_node(*args)
        Filterly::Node.new(*args)
      end
    end
  end
end
