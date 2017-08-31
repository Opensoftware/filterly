# frozen_string_literal: true

require File.expand_path('../to_sql/expression_factory', __FILE__)
require File.expand_path('../to_sql/container', __FILE__)

class Interpreter
  class ToSql
    def call(ast)
      visit(ast)
    end

    # @api private
    def visit(node)
      return ToSql::ExpressionFactory.new.call(node) if node.node_with_attr_name? &&
          Container::VISITORS_MAPPER.key?(node.left.value)

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
      return visit(left) if right.nil?
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
