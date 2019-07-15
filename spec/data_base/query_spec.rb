# frozen_string_literal: true

require 'data_base.rb'
require 'data_base/store.rb'
require 'data_base/query.rb'
require 'filter_expression_tree.rb'
# require 'project.rb'
# require 'index.rb'

RAW_DATA = [
  {
    'created_date' => '2010-04-01 13:35',
    'finish_date' => '2010-05-15',
    'internal_bid' => '45.00',
    'project' => 'the hobbit',
    'shot' => '01',
    'status' => 'scheduled',
    'version' => '64'
  },
  {
    'created_date' => '2001-04-01 06:47',
    'finish_date' => '2001-05-15',
    'internal_bid' => '15.00',
    'project' => 'lotr',
    'shot' => '03',
    'status' => 'finished',
    'version' => '16'
  },
  {
    'created_date' => '2006-08-04 07:22',
    'finish_date' => '2006-07-22',
    'internal_bid' => '45.00',
    'project' => 'king kong',
    'shot' => '42',
    'status' => 'scheduled',
    'version' => '128'
  },
  {
    'created_date' => '2010-03-22 01:10',
    'finish_date' => '2010-05-15',
    'internal_bid' => '22.80',
    'project' => 'the hobbit',
    'shot' => '40',
    'status' => 'finished',
    'version' => '32'
  },
  {
    'created_date' => '2006-10-15 09:14',
    'finish_date' => '2006-07-22',
    'internal_bid' => '30.00',
    'project' => 'king kong',
    'shot' => '42',
    'status' => 'not required',
    'version' => '128'
  }
].freeze

describe Query do
  before :each do
    @data_store = Store.new
    @table = @data_store.create_table Project do |t|
      t.string :project # max 64
      t.string :shot # max 64
      t.integer :version # 0 and 65535
      t.string :status # max 32
      t.date :finish_date # YYYY-MM-DD
      t.float :internal_bid
      t.timestamp :created_date # YYYY-MM-DD HH:MM format
    end

    indexes = @data_store.add_index(
      Project,
      %w[project shot version],
      unique: true
    )
    @index = indexes.first
  end

  describe 'when querying' do
    before :each do
      @records_raw_data = RAW_DATA

      @records_raw_data.each do |data|
        @data_store.store_record(Project, data)
      end
    end

    describe 'select' do
      it 'should return all columns when no select clause is specified' do
        results = @data_store.new_query
                             .from(Project)
                             .run

        expect(results).to eq([
                                { created_date: '2010-04-01 13:35',
                                  finish_date: '2010-05-15',
                                  internal_bid: 45.0,
                                  project: 'the hobbit',
                                  shot: '01',
                                  status: 'scheduled',
                                  version: 64 },
                                { created_date: '2001-04-01 06:47',
                                  finish_date: '2001-05-15',
                                  internal_bid: 15.0,
                                  project: 'lotr',
                                  shot: '03',
                                  status: 'finished',
                                  version: 16 },
                                { created_date: '2010-03-22 01:10',
                                  finish_date: '2010-05-15',
                                  internal_bid: 22.80,
                                  project: 'the hobbit',
                                  shot: '40',
                                  status: 'finished',
                                  version: 32 },
                                { created_date: '2006-10-15 09:14',
                                  finish_date: '2006-07-22',
                                  internal_bid: 30.00,
                                  project: 'king kong',
                                  shot: '42',
                                  status: 'not required',
                                  version: 128 }
                              ])
      end

      it 'should return columns specified on the select clause' do
        results = @data_store.new_query
                             .select(%w[project shot version status])
                             .from(Project)
                             .run

        expect(results).to eq(
          [{ project: 'the hobbit', shot: '01', status: 'scheduled', version: 64 },
           { project: 'lotr', shot: '03', status: 'finished', version: 16 },
           { project: 'the hobbit', shot: '40', status: 'finished', version: 32 },
           { project: 'king kong',  shot: '42', status: 'not required', version: 128 }]
        )
      end
    end

    describe 'where' do
      it 'should select specific columns and apply the where clause ' do
        expression = FilterExpressionTree.build("finish_date=2006-07-22")
        results = @data_store.new_query
                             .select(%w[project shot version status])
                             .where(expression)
                             .from(Project)
                             .run

        expect(results).to eq(
          [{ project: 'king kong', shot: '42', status: 'not required', version: 128 }]
        )
      end

    end

    describe 'sort_by' do
      it 'should sort by specified columns and apply where clause' do
        results = @data_store.new_query
                             .select(%w[project shot version status])
                             .order_by(%w[finish_date internal_bid])
                             .from(Project)
                             .run

        expect(results).to eq(
          [
            { project: 'lotr', shot: '03', status: 'finished', version: 16 },
            { project: 'king kong',  shot: '42', status: 'not required', version: 128 },
            { project: 'the hobbit', shot: '40', status: 'finished', version: 32 },
            { project: 'the hobbit', shot: '01', status: 'scheduled', version: 64 }
          ]
        )
      end

      it 'should sort by timestamp column and where clause' do
        results = @data_store.new_query
                             .select(%w[project created_date])
                             .order_by(%w[created_date])
                             .from(Project)
                             .run

        expect(results).to eq(
          [{ created_date: '2001-04-01 06:47', project: 'lotr' },
           { created_date: '2006-10-15 09:14', project: 'king kong' },
           { created_date: '2010-03-22 01:10', project: 'the hobbit' },
           { created_date: '2010-04-01 13:35', project: 'the hobbit' }]
        )
      end
    end

    describe 'group_by and aggregated functions' do
      it 'should apply sum by specific column after grouping by' do
        results = @data_store.new_query
                             .select(%w[project internal_bid:sum])
                             .from(Project)
                             .group_by(%w[project])
                             .run

        expect(results).to eq(
          [
            { project: 'the hobbit', internal_bid: 67.8 },
            { project: 'lotr', internal_bid: 15.0 },
            { project: 'king kong', internal_bid: 30.0 }
          ]
        )
      end

      it 'should get the min for a column after grouping by', :focus do
        results = @data_store.new_query
                             .select(%w[project internal_bid:min])
                             .from(Project)
                             .group_by(%w[project])
                             .run

        expect(results).to eq(
          [
            { project: 'the hobbit', internal_bid: 22.8 },
            { project: 'lotr', internal_bid: 15.0 },
            { project: 'king kong', internal_bid: 30.0 }
          ]
        )
      end

      it 'should get the max for a column after grouping by' do
        results = @data_store.new_query
                             .select(%w[project internal_bid:max])
                             .from(Project)
                             .group_by(%w[project])
                             .run

        expect(results).to eq(
          [
            { project: 'the hobbit', internal_bid: 45.0 },
            { project: 'lotr', internal_bid: 15.0 },
            { project: 'king kong', internal_bid: 30.0 }
          ]
        )
      end

      it 'should count the amount of distinct values in a column after grouping by' do
        results = @data_store.new_query
                             .select(%w[project internal_bid:uniq:count])
                             .from(Project)
                             .group_by(%w[project])
                             .run

        expect(results).to eq(
          [
            { project: 'the hobbit', internal_bid: 2 },
            { project: 'lotr', internal_bid: 1 },
            { project: 'king kong', internal_bid: 1 }
          ]
        )
      end

      it 'should collect the distinct values in a number column' do
        results = @data_store.new_query
                             .select(%w[project internal_bid:uniq])
                             .from(Project)
                             .group_by(%w[project])
                             .run

        expect(results).to eq(
          [
            { project: 'the hobbit', internal_bid: [45.0, 22.8] },
            { project: 'lotr', internal_bid: [15.0] },
            { project: 'king kong', internal_bid: [30.0] }
          ]
        )
      end

      it 'should collect the distinct values in a text column' do
        results = @data_store.new_query
                             .select(%w[project shot:uniq])
                             .from(Project)
                             .group_by(%w[project])
                             .run

        expect(results).to eq(
          [
            { project: 'the hobbit', shot: %w[01 40] },
            { project: 'lotr', shot: ['03'] },
            { project: 'king kong', shot: ['42'] }
          ]
        )
      end

      it 'should collect the distinct values in a text column and a number column' do
        results = @data_store.new_query
                             .select(%w[project internal_bid:uniq shot:uniq])
                             .from(Project)
                             .group_by(%w[project])
                             .run

        expect(results).to eq(
          [{ internal_bid: [45.0, 22.8], project: 'the hobbit', shot: %w[01 40] },
           { internal_bid: [15.0], project: 'lotr', shot: ['03'] },
           { internal_bid: [30.0], project: 'king kong', shot: ['42'] }]
        )
      end

    end
  end
end
