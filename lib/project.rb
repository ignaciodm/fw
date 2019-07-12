# frozen_string_literal: true

require 'model.rb'

# add comment
class Project
  include Model

  attr_accessor :project,
                :shot,
                :version,
                :status,
                :finish_date,
                :internal_bid,
                :created_date

  def to_h
    { project: project,
      shot: shot,
      version: version,
      status: status,
      finish_date: finish_date,
      internal_bid: internal_bid,
      created_date: created_date }
  end

  def to_query_result
    { project: project,
      shot: shot,
      version: version,
      status: status,
      finish_date: finish_date.strftime('%F'),
      internal_bid: internal_bid,
      created_date: created_date.strftime('%F %H:%M') }
  end
end
