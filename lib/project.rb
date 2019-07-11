# frozen_string_literal: true

require 'model.rb'

# add comment
class Project
  extend Model

  attr_accessor :project,
                :shot,
                :version,
                :status,
                :finish_date,
                :internal_bid,
                :created_date

  def initialize(*args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def to_h
    { project: project,
      shot: shot,
      version: version,
      status: status,
      finish_date: finish_date,
      internal_bid: internal_bid,
      created_date: created_date }
  end
end
