# frozen_string_literal: true

require_relative 'sql_struct_parts'
require_relative 'sql_builder'

class UserQueryPipeline
  attr_reader :sql_struct_parts

  def initialize(sql_struct_parts:)
    @sql_struct_parts = sql_struct_parts
  end

  def self.new(params:)
    super(sql_struct_parts: SqlStructParts.new(deps: params))
  end

  def call
    sql_struct_parts << something_special

    sql_builder = SqlBuilder.new(sql_struct_parts: sql_struct_parts, model_name: 'users')

    [sql_builder.count_query, sql_builder.sql_query]
  end

  def something_special
    {
      where: ["user.ethnicity IN('celts', 'slavic')"]
    }
  end
end
