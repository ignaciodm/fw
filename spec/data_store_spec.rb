require 'data_store.rb'
require 'project.rb'

describe DataStore do
  before :each do
    @table = DataStore.new.create_table Project do |t|
      t.string :project #max 64
      t.string :shot #max 64
      t.integer :version # 0 and 65535
    end
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

   it 'should set the table name' do
    expect(@table.name).to eq('project')
  end
end
