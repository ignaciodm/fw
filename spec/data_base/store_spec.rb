# frozen_string_literal: true

require 'data_base.rb'
require 'data_base/store.rb'
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
describe Store do
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
      %i[project shot version],
      unique: true
    )
    @index = indexes.first
  end

  it { expect(@table.columns.size).to eq(7) }
  it { expect(@table.columns).to all(be_an(Column::Base)) }
  it {
    expect(@table.columns.first)
      .to have_attributes(name: 'project')
  }
  it {
    expect(@table.columns.first)
      .to be_an(Column::String)
  }
  # it {
  #   expect(@table.columns[1])
  #     .to have_attributes(type: String, name: 'shot')
  # }
  # it {
  #   expect(@table.columns[2])
  #     .to have_attributes(type: Integer, name: 'version')
  # }

  it { expect(@table.name).to eq('project') }

  it { expect(@data_store.schema.project.indexes.first).to eq(@index) }
  # it {expect(@index).to be_an(Index)}
  # it {expect(@index.keys).to eq([:project, :shot, :version])}
  # it {expect(@index.options).to eq({unique:true})}

  describe 'when adding an array of json projects' do
    before :each do
      @records_raw_data = RAW_DATA

      @records_raw_data.each do |data|
        @data_store.store_record(Project, data)
      end
    end

    it 'should set keep an index table for the projects table' do
      expect(@data_store.schema.project.indexes.first.table).to eq(
        'king kong.42.128' => 3,
        'lotr.03.16' => 1,
        'the hobbit.01.64' => 0,
        'the hobbit.40.32' => 2
      )
    end

    it 'should override records with the same combined key' do
      expect(@table.records.size).to eq(4)
    end

    it { expect(@table.records).to all(be_an(Project)) }

    it {
      expect(@table.records.first)
        .to have_attributes(project: 'the hobbit')
    }
  end

  describe 'when adding invalid projects' do
    it 'should not add projects with invalid project title' do
      expect { @data_store.store_record(Project, project: 'loooooooooooooooooooooong') }.to raise_error
    end

    it 'should not add projects with invalid project title' do
      begin
        @data_store.store_record(Project, project: 'loooooooooooooooooooooong')
      rescue StandardError => e
        expect(@table.records.size).to eq(0)
      end
    end
  end
end
