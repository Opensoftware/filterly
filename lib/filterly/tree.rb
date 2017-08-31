# frozen_string_literal: true

require 'ast/sexp'

module Filterly
  class Tree
    attr_reader :root_node

    def initialize(root_node)
      @root_node = root_node
    end

    def self.new(root_node)
      ensure_ast_node!(root_node)
      ensure_ast_root!(root_node)

      super(root_node)
    end

    def self.initialize_with_filters
      new(
        Filterly::NodeBuilder.build_custom_node(
          type: :root,
          args: [:filters, nil, nil]
        )
      )
    end

    def extend_ast(node_attr_name, new_node, stmt_type)
      @root_node = TreeTraverser
        .new(@root_node)
        .extend_ast(node_attr_name, new_node, stmt_type)
    end

    def prepend_ast(new_node, stmt_type)
      @root_node = TreeTraverser.new(@root_node).prepend_ast(new_node, stmt_type)
    end

    def to_ast
      root_node
    end

    def to_s
      root_node.to_s
    end

    # @apir private
    def self.ensure_ast_root!(root_node)
      raise 'Not a tree root!' if root_node.type != :root
    end

    # @api private
    def self.ensure_ast_node!(root_node)
      raise 'Not a Filterfly:Node!' if root_node.nil? || !root_node.is_a?(Filterly::Node)
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
            self
            .class
            .new(ast_node.left)
            .extend_ast(node_attr_name, new_node, stmt_type),
            self
            .class
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
