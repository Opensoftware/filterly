# frozen_string_literal: true

class Interpreter
  class ToSql
    module Container
      VISITORS_MAPPER = {
        category_ids: 'course_category_ids',
        course_annuals: 'course_annual_id'
      }.freeze
    end
  end
end
