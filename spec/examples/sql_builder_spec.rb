# frozen_string_literal: true

require 'spec_helper'

require 'examples/sql_builder'
require 'examples/sql_struct_parts'

RSpec.describe SqlBuilder do
  subject do
    described_class.new(sql_struct_parts: sql_struct, model_name: 'users')
  end

  let(:sql_struct) do
    SqlStructParts.new(
      deps: {
        select: 'users.*',
        from: '(SELECT users WHERE id IN(1,2,3)) as users',
        where: ['(users.name = "Pszemek" OR users.age > 24)', 'users.status = "adult"'],
        joins: ['LEFT JOIN courses c ON(c.id=users.course_id)'],
        limit: 10,
        order: 'users.id ASC',
        offset: 5,
        preload: %i[courses addresses]
      }
    )
  end

  let(:sql_struct_no_from_or_select) do
    SqlStructParts.new(
      deps: {
        select: [],
        from: nil,
        where: ['users.name = "Pszemek" AND users.age > 24'],
        joins: ['LEFT JOIN courses c ON(c.id=users.course_id)'],
        limit: 10,
        order: 'users.id ASC',
        offset: 5,
        preload: %i[courses addresses]
      }
    )
  end

  describe '#sql_query' do
    it 'returns sql query' do
      expect(subject.sql_query.tr("\n", ' ')).to eql(
        <<~SQL.tr("\n", ' ')
          SELECT users.* FROM (SELECT users WHERE id IN(1,2,3)) as users
          LEFT JOIN courses c ON(c.id=users.course_id)
          WHERE (users.name = "Pszemek" OR users.age > 24) AND users.status = "adult"
          ORDER BY users.id ASC
          LIMIT 10
          OFFSET 5
        SQL
      )
    end

    it 'uses model_name when from is upsent' do
      result = described_class.new(
        sql_struct_parts: sql_struct_no_from_or_select,
        model_name: 'users'
      ).sql_query

      expect(result.tr("\n", ' ')).to eql(
        <<~SQL.tr("\n", ' ')
          SELECT * FROM users
          LEFT JOIN courses c ON(c.id=users.course_id)
          WHERE users.name = "Pszemek" AND users.age > 24
          ORDER BY users.id ASC
          LIMIT 10
          OFFSET 5
        SQL
      )
    end
  end

  describe '#count_query' do
    it 'returns sql count query' do
      expect(subject.count_query.tr("\n", ' ')).to eql(
        <<~SQL.tr("\n", ' ')
          SELECT COUNT(users.*) FROM (SELECT users WHERE id IN(1,2,3)) as users
          LEFT JOIN courses c ON(c.id=users.course_id)
          WHERE (users.name = "Pszemek" OR users.age > 24) AND users.status = "adult"
        SQL
      )
    end
  end
end
