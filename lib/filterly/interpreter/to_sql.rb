# frozen_string_literal: true

module Filterly
  class Interpreter
    class ToSql
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
      def visit_root(_value, left, _right)
        visit(left)
      end

      # @api private
      def visit_statement(value, left, right)
        case value
        when :and
          "#{visit(left)} AND #{visit(right)}"
        when :or
          "(#{visit(left)} OR #{visit(right)})"
        else
          ''
        end
      end

      # @api private
      def visit_expression(value, left, right)
        case value
        when :op_equal
          "#{visit(left)}=#{visit(right)}"
        when :op_in
          "#{visit(left)} IN(#{visit(right).join(',')})"
        else
          ''
        end
      end

      # @api private
      def visit_attr_name(value, _left, _right)
        value
      end

      # @api private
      def visit_attr_value(value, _left, _right)
        "'#{value}'"
      end

      # @api private
      def visit_attr_array(value, left, right)
        if right
          ["'#{value}'", visit(left), visit(right)].flatten
        else
          "'#{value}'"
        end
      end
    end
  end
end
