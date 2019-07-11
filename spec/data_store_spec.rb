# frozen_string_literal: true

require 'data_store.rb'
require 'project.rb'
require 'index.rb'

describe DataStore do
  before :each do
    @data_store = DataStore.new
    @table = @data_store.create_table Project do |t|
      t.string :project # max 64
      t.string :shot # max 64
      t.integer :version # 0 and 65535
    end

    indexes =  @data_store.add_index Project, [:project, :shot, :version], unique: true
    @index = indexes.first
  end

  #  PROJECT: The project name or code name of the shot. (Text, max size 64 char)
  #       SHOT: The name of the shot. (Text, max size 64 char)
  #       VERSION: The current version of the file. (Integer, between 0 and 65535 inclusive)
  #       STATUS: The current status of the shot. (Text, max size 32 char)
  #       FINISH_DATE: The date the work on the shot is scheduled to end. (Date in YYYY-MM-DD format)
  #       INTERNAL_BID: The amount of days we estimate the work on this shot will take. (Floating-point number, between 0 and 65535)
  #       CREATED_DATE: The time and date when this record is being added to the system. (Timestamp in YYYY-MM-DD HH:MM format)

  it 'should create a table with specific columns' do
    expect(@table.columns.size).to eq(3)
    expect(@table.columns).to all(be_an(Column))
    expect(@table.columns.first).to have_attributes(type: String, name: 'project')
    expect(@table.columns[1]).to have_attributes(type: String, name: 'shot')
    expect(@table.columns[2]).to have_attributes(type: Integer, name: 'version')
  end

  it { expect(@table.name).to eq('project') }

  it {expect(@data_store.schema.project.indexes.first).to eq(@index)}
  # it {expect(@index).to be_an(Index)}
  # it {expect(@index.keys).to eq([:project, :shot, :version])}
  # it {expect(@index.options).to eq({unique:true})}

  describe 'when adding an array of json projects' do
    before :each do
      @records_raw_data = [
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
      ]

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

    it { expect(@table.records.first).to have_attributes(project: 'the hobbit') }
    
  end
end
