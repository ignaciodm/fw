# frozen_string_literal: true

require_relative 'data_base/store.rb'
require_relative 'project.rb'
require_relative 'file_importer.rb'

class InvalidArguments < StandardError
  def initialize(msg = 'Invalid arguments')
    super
  end
end

VALID_SELECT_AGGREGATED_FUNCTIONS = %w[min max collect count sum].freeze

class ProjectQueryCommandLine
  CLAUSES_DEF = {
    s: {
      method: 'select',
      parser: proc do |str| str.downcase.split(',') end,
      validate: proc do |str|
                  str.split(',').each do |value|
                    key, *functions = value.split(':')
                    next if functions.empty?

                    functions.each do |function|
                      unless VALID_SELECT_AGGREGATED_FUNCTIONS.include?(function)
                        raise InvalidArguments, "function not valid: #{function}. Valid options are #{VALID_SELECT_AGGREGATED_FUNCTIONS}"
                        end
                    end
                  end
                end
    },
    o: {
      method: 'order_by',
      parser: proc do |str| str.downcase.split(',') end
    },
    f: {
      method: 'where',
      parser: proc do |str|
                [str.downcase.split('=')].to_h
              end
    },
    g: {
      method: 'group_by',
      parser: proc do |str| str.downcase.split(',') end
    }
  }.freeze

  def self.validate_arguments(string_argv)
    #  1) parse arguments

    if string_argv.empty?
      raise InvalidArguments, "How to use this command line query tool? \n" \
                              "Here are a few examples: \n" \
                              " ruby query.rb -s PROJECT,SHOT,VERSION \n" \
                              "\n" \
                              " ruby query.rb -s PROJECT,SHOT,VERSION,STATUS -o FINISH_DATE,INTERNAL_BID \n" \
                              "\n" \
                              " ruby query.rb -s PROJECT,SHOT:count -g PROJECT \n" \
                              "\n" \
                              " ruby query.rb -s PROJECT,INTERNAL_BID:min,SHOT:max -g PROJECT \n" \
                              "\n" \
                              " ruby query.rb -s PROJECT,INTERNAL_BID:sum,SHOT:collect -g PROJECT \n" \
                              "\n" \
                              " ruby query.rb -s PROJECT,SHOT,VERSION,STATUS -f FINISH_DATE=2006-07-22 \n" \
                              "\n" \
                              " ruby query.rb -s PROJECT,INTERNAL_BID:sum,SHOT:collect -g PROJECT \n" \
                              "\n" \
                              " ruby query.rb -s PROJECT,SHOT,VERSION,STATUS -o FINISH_DATE,INTERNAL_BID \n" \
                              "\n\n\n" \
                              "Options:\n" \
                              "1) -s (select) comma separated list \n" \
                              "supported aggregated functions: #{VALID_SELECT_AGGREGATED_FUNCTIONS}\n\n" \
                              "2) -f (filter) comma separated list \n\n" \
                              "3) -o (order by) comma separated list \n\n" \
                              "4) -g (group_by) only one group supported \n\n"

    end

    arguments = string_argv.split(' ')
    # validate options
    command_line_options = arguments.select { |str| str.start_with?('-') }
    command_line_options.each do |option|
      option_key = option.sub '-', ''
      raise InvalidArguments, "options not valid: #{option}. Valid options are -s -o -f -g" unless CLAUSES_DEF[option_key.to_sym]
    end

    command_line_options_with_values = arguments.each_slice(2).to_a

    command_line_options_with_values.each do |clause|
      command_line_option = clause[0].sub '-', ''
      command_line_option_arg = clause[1]

      validate = CLAUSES_DEF[command_line_option.to_sym][:validate]

      validate&.call(command_line_option_arg)
    end
end

  def self.import_file
    FileImporter.new(
      path: File.expand_path('../data/file_sample.txt', __dir__),
      separator: '|'
    )
end

  def self.create_store
    data_store = Store.new
    data_store.create_table Project do |t|
      t.string :project # max 64
      t.string :shot # max 64
      t.integer :version # 0 and 65535
      t.string :status # max 32
      t.date :finish_date # YYYY-MM-DD
      t.float :internal_bid
      t.timestamp :created_date # YYYY-MM-DD HH:MM format
    end

    data_store.add_index(
      Project,
      %i[project shot version],
      unique: true
    )

    data_store
    end

  def self.save_record_in_store(file_importer, data_store)
    file_importer.lines_as_hash.each do |data|
      data_store.store_record(Project, data)
    end
  end

  def self.build_query_and_run(command_line_options_with_values, data_store)
    q = command_line_options_with_values.reduce(data_store.new_query) do |query, clause|
      command_line_option = clause[0].sub '-', ''
      command_line_option_arg = clause[1]

      method = CLAUSES_DEF[command_line_option.to_sym][:method]
      parser = CLAUSES_DEF[command_line_option.to_sym][:parser]

      query.send(method.to_sym, parser.call(command_line_option_arg))
    end

    results = q.from(Project).run
  end

  def self.run(string_argv)
    # 1)
    validate_arguments(string_argv)

    # 2)
    file_importer = import_file

    # 3)
    data_store = create_store

    # 4)
    save_record_in_store(file_importer, data_store)

    # 5) Query results

    results = build_query_and_run(string_argv.split(' ').each_slice(2).to_a, data_store)

    # 6) Print results
    # puts results

    results.map do |result|
      values = result.values.map do |value|
        value.is_a?(Enumerator) ? "[#{value.to_a.join(',')}]" : value
      end
      values.join(',')
    end
  end
end
