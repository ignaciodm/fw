# frozen_string_literal: true

require 'data_base/column/string.rb'

describe 'Column::String' do
  
  describe 'validation' do
    before :each do
      @column = Column::String.new(name: 'name')
    end

    it { expect(@column.is_valid?('some string', length: {max: 15 })).to be_truthy }
    it { expect(@column.is_valid?('some string longer than 15 characters', length: {max: 15 })).to be_falsy }
  end

   describe '#value_casted_to_type' do
    before :each do
      @column = Column::String.new(name: 'name')
    end

    it { expect(@column.value_casted_to_type('some string')).to be('some string') }
  end

end
