# frozen_string_literal: true

require 'data_base.rb'
require 'data_base/store.rb'
require 'data_base/query.rb'
require 'project.rb'
# require 'index.rb'

describe Project do
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

  before :each do
    @records_raw_data = RAW_DATA

    @records_raw_data.each do |data|
      @data_store.store_record(Project, data)
    end
  end
end
