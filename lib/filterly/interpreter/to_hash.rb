# frozen_string_literal: true

module Filterly
  class Interpreter
    class ToHash
      def call(ast)
        visit(ast)
      end

      # @api private
      def visit(node)
        send(
          :"visit_#{node.type}",
          node.children[0],
          node.children[1],
          node.children[2]
        )
      end

      # @api private
      def visit_root(value, left, _right)
        { "#{value}": visit(left) }
      end

      # @api private
      def visit_statement(value, left, right)
        case value
        when :and
          [visit(left), visit(right)].flatten
        when :or
          { or: [visit(left), visit(right)] }
        else
          {}
        end
      end

      # @api private
      def visit_expression(value, left, right)
        case value
        when :op_equal
          { "#{visit(left)}": visit(right) }
        when :op_in
          { "#{visit(left)}": visit(right) }
        else
          {}
        end
      end

      # @api private
      def visit_attr_name(value, _left, _right)
        value
      end

      # @api private
      def visit_attr_value(value, _left, _right)
        value
      end

      # @api private
      def visit_attr_array(value, left, right)
        if right
          [value, visit(left), visit(right)].flatten
        else
          value
        end
      end
    end
  end
end
