# frozen_string_literal: true

require 'spec_helper'
require 'filterly/node'

RSpec.describe Filterly::Node do
  subject do
    described_class.new(:expression, params)
  end

  describe '#attr_name_equal?' do
    let(:params) do
      [
        :op_equal,
        described_class.new(:attr_name, [:annual_id, nil, nil]),
        described_class.new(:attr_value, [223, nil, nil])
      ]
    end

    it 'checks whether node has annual_id attribute name' do
      expect(subject.attr_name_equal?(:annual_id)).to be_truthy
    end

    it 'checks whether node has incorrect attribute name' do
      expect(subject.attr_name_equal?(:semester)).to be_falsy
    end
  end

  describe '#node_with_attr_name?' do
    let(:params) do
      [
        :op_equal,
        described_class.new(:attr_name, [:annual_id, nil, nil]),
        nil
      ]
    end

    it 'returns true for attr_name left leaf type' do
      expect(subject.node_with_attr_name?).to be_truthy
    end

    it 'returns false for no attr_name left leaf' do
      subject = described_class.new(
        :smth,
        [
          :or,
          described_class.new(:attr_names)
        ]
      )

      expect(subject.node_with_attr_name?).to be_falsy
    end

    it 'returns false for empty node' do
      subject = described_class.new(:root, [])

      expect(subject.node_with_attr_name?).to be_falsy
    end
  end
end
