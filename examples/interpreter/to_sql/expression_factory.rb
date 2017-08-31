# frozen_string_literal: true

require_relative 'container'

class Interpreter
  class ToSql
    class ExpressionFactory
      include Container

      def call(node)
        visit(node)
      end

      # @api private
      def visit(node)
        visit_path = if node.left
                       VISITORS_MAPPER.fetch(node.left.value) { node.type }
                     else
                       node.type
                     end

        send(
          :"visit_#{visit_path}",
          node.children[0],
          node.children[1],
          node.children[2]
        )
      end

      # @api private
      def visit_course_category_ids(value, _left, right)
        <<~SQL
          EXISTS(
            SELECT TRUE FROM category_courses
            WHERE category_courses.category_id #{determine_values(value, right)}
            AND courses.id = category_courses.course_id
          )
        SQL
      end

      # @api private
      def visit_course_annual_id(value, _left, right)
        <<~SQL
          courses.annual_id #{determine_values(value, right)}
        SQL
      end

      # @api private
      def visit_attr_value(value, _left, _right)
        "'#{value}'"
      end

      # @api private
      def determine_values(op, node)
        case op
        when :op_equal
          "= #{visit(node)}"
        when :op_in
          "IN(#{visit(node).join(',')})"
        end
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
