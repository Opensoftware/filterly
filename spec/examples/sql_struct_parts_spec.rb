# frozen_string_literal: true

require 'spec_helper'
require './examples/sql_struct_parts'

RSpec.describe SqlStructParts do
  subject do
    described_class.new(deps: deps)
  end

  let(:deps) do
    {
      select: ['users.*'],
      where: ['user.id IN(1,2,3)'],
      limit: 20,
      joins: ['LEFT JOIN courses c ON(c.id=b.lk)']
    }
  end

  describe '#new' do
    it 'creates deps with default values' do
      expect(subject.deps).to eql(
        select: ['users.*'],
        limit: 20,
        where: ['user.id IN(1,2,3)'],
        joins: ['LEFT JOIN courses c ON(c.id=b.lk)']
      )
    end
  end

  describe '#with' do
    it 'merges new params with the old ones' do
      result = subject
        .with(
          limit: 10,
          offset: 0,
          joins: ['INNER JOIN addresses a ON(a.id=b.address_id)']
        )
        .with(from: 'users', select: ['id, surname'], where: ['user.age > 45'])

      expect(result.deps).to eql(
        from: 'users',
        joins: [
          'LEFT JOIN courses c ON(c.id=b.lk)',
          'INNER JOIN addresses a ON(a.id=b.address_id)'
        ],
        limit: 0,
        offset: 0,
        order: '',
        preload: [],
        search_query: '',
        select: ['users.*', 'id, surname'],
        where: ['user.id IN(1,2,3)', 'user.age > 45']
      )
    end
  end

  describe '#initialize_dependencies' do
    it 'allows to call attributes by methods' do
      result = subject.with(limit: 11)

      expect(result.limit).to eql(11)
      expect(result.where).to eql(['user.id IN(1,2,3)'])
    end
  end
end
