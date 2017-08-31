# frozen_string_literal: true

require 'spec_helper'
require 'filterly/tree'
require 'filterly/node'

RSpec.describe Filterly::Tree do
  subject do
    described_class.new(ast)
  end

  let(:ast) do
    Filterly::Node.new(
      :root,
      [
        :filters,
        Filterly::Node.new(
          :statement,
          [
            :and,
            Filterly::Node.new(
              :expression,
              [
                :op_equal,
                Filterly::Node.new(:attr_name, [node_attr_name, nil, nil]),
                Filterly::Node.new(
                  :attr_array,
                  [
                    nil,
                    Filterly::Node.new(:attr_value, [123, nil, nil]),
                    Filterly::Node.new(
                      :attr_value,
                      [
                        223,
                        Filterly::Node.new(:attr_value, [323, nil, nil]),
                        nil
                      ]
                    )
                  ]
                )
              ]
            ),
            Filterly::Node.new(
              :expression,
              [
                :op_equal,
                Filterly::Node.new(:attr_name, [:annual_id, nil, nil]),
                Filterly::Node.new(:attr_value, [223, nil, nil])
              ]
            )
          ]
        )
      ]
    )
  end

  let(:node_attr_name) do
    :course_id
  end

  let(:new_node) do
    Filterly::Node.new(
      :expression,
      [
        :op_equal,
        Filterly::Node.new(:attr_name, [:whatever_id, nil, nil]),
        Filterly::Node.new(:attr_value, [13, nil, nil])
      ]
    )
  end

  describe '#initialize' do
    it 'Throws exception when trying to create tree on nil object' do
      expect { described_class.new(nil) }.to raise_error('Not a Filterfly:Node!')
    end

    it 'Throws exception when trying to create tree on not Filterfly::Node object' do
      expect { described_class.new(123) }.to raise_error('Not a Filterfly:Node!')
    end

    it 'Throws exception when trying to create tree on not root node' do
      expect { described_class.new(new_node) }.to raise_error('Not a tree root!')
    end
  end

  describe '#initialize_with_filters' do
    it 'initializes Tree with filters root' do
      expect(described_class.initialize_with_filters.root_node.to_a).to match_array(
        [
          :root,
          [
            :filters,
            [],
            []
          ]
        ]
      )
    end
  end

  describe '#extend_ast' do
    it 'adds a new node to specific node and returns root' do
      subject.extend_ast(node_attr_name, new_node, :or)

      expect(subject.to_ast.to_a).to match_array(
        [
          :root,
          [
            :filters,
            [
              :statement,
              [
                :and,
                [
                  :statement,
                  [
                    :or,
                    [
                      :expression,
                      [
                        :op_equal,
                        [:attr_name, [:whatever_id, [], []]],
                        [:attr_value, [13, [], []]]
                      ]
                    ],
                    [
                      :expression,
                      [
                        :op_equal,
                        [:attr_name, [:course_id, [], []]],
                        [
                          :attr_array,
                          [
                            nil,
                            [:attr_value, [123, [], []]],
                            [
                              :attr_value,
                              [
                                223,
                                [:attr_value, [323, [], []]],
                                []
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ]
                ],
                [
                  :expression,
                  [
                    :op_equal,
                    [:attr_name, [:annual_id, [], []]],
                    [:attr_value, [223, [], []]]
                  ]
                ]
              ]
            ],
            []
          ]
        ]
      )
    end
  end

  describe '#prepend_ast' do
    it 'adds a new node to root of the tree and returns root' do
      expect(subject.to_ast).to eql(ast)

      subject.prepend_ast(new_node, :or)

      expect(subject.to_ast.to_a).to match_array(
        [
          :root, [
            :filters, [
              :statement, [
                :or,
                [
                  :expression, [
                    :op_equal,
                    [:attr_name, [:whatever_id, [], []]],
                    [:attr_value, [13, [], []]]
                  ]
                ],
                [
                  :statement,
                  [
                    :and,
                    [
                      :expression,
                      [
                        :op_equal,
                        [:attr_name, [:course_id, [], []]],
                        [
                          :attr_array,
                          [
                            nil,
                            [:attr_value, [123, [], []]],
                            [
                              :attr_value,
                              [
                                223,
                                [:attr_value, [323, [], []]],
                                []
                              ]
                            ]
                          ]
                        ]
                      ]
                    ],
                    [
                      :expression,
                      [
                        :op_equal,
                        [:attr_name, [:annual_id, [], []]],
                        [:attr_value, [223, [], []]]
                      ]
                    ]
                  ]
                ]
              ]
            ],
            []
          ]
        ]
      )
    end
  end
end
