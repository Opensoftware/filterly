# frozen_string_literal: true

class SqlBuilder
  attr_reader :sql_struct_parts, :model_name

  def initialize(sql_struct_parts:, model_name:)
    @sql_struct_parts = sql_struct_parts
    @model_name = model_name
  end

  def preloads
    ssp.preloads
  end

  def sql_query
    <<~SQL
      SELECT #{select} FROM #{from} #{ssp.joins.join(' ')}
      WHERE #{ssp.where.join(' AND ')}
      ORDER BY #{ssp.order}
      LIMIT #{ssp.limit}
      OFFSET #{ssp.offset}
    SQL
  end

  def count_query
    <<~SQL
      SELECT #{count_select} FROM #{from} #{ssp.joins.join(' ')}
      WHERE #{ssp.where.join(' AND ')}
    SQL
  end

  def count_select
    "COUNT(#{select})"
  end

  def select
    return '*' if ssp.select.empty?
    ssp.select
  end

  def from
    return model_name if ssp.from.empty?
    ssp.from
  end

  def to_s
    to_sql.to_s
  end

  alias ssp sql_struct_parts
end
