# frozen_string_literal: true

require 'data_base/column.rb'

describe 'Column' do
  describe 'String columns' do
    before :each do
      @column = Column.new(type: String, name: 'name')
    end

    it { expect(@column.value_casted_to_type('some string')).to be('some string') }
  end

  describe 'Integer columns' do
    before :each do
      @column = Column.new(type: Integer, name: 'name')
    end

    it { expect(@column.value_casted_to_type('123')).to be(123) }
  end

  describe 'Float columns' do
    before :each do
      @column = Column.new(type: Float, name: 'name')
    end

    it { expect(@column.value_casted_to_type('123.45')).to be(123.45) }
  end

  describe 'Date columns' do
    before :each do
      @column = Column.new(type: Date, name: 'name')
    end

    it { expect(@column.value_casted_to_type('2010-05-15')).to eq(Date.parse('2010-05-15')) }
  end

  describe 'Time columns' do
    before :each do
      @column = Column.new(type: Time, name: 'name')
    end

    it { expect(@column.value_casted_to_type('2010-04-01 13:35')).to eq(Time.parse('2010-04-01 13:35')) }
  end
end
