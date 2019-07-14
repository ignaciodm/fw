# frozen_string_literal: true

require_relative 'data_base/store.rb'
require_relative 'project.rb'
require_relative 'file_importer.rb'

# add coment
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
      parser: proc do |str|
        str ? str.downcase.split(',') : nil
      end,
      validate: proc do |str|
        (str || '').split(',').each do |value|
          _key, *functions = value.split(':')
          next if functions.empty?

          functions.each do |function|
            unless VALID_SELECT_AGGREGATED_FUNCTIONS.include?(function)
              raise InvalidArguments, "function not valid: #{function}. " \
                                      "Valid options are #{VALID_SELECT_AGGREGATED_FUNCTIONS}"
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

  def self.validate_empty_arguments(string_argv)
    return unless string_argv.empty?

    raise InvalidArguments, File.read(File.expand_path('../data/how_to_use.txt', __dir__))
  end

  def self.validate_options(arguments)
    command_line_options = arguments.select { |str| str.start_with?('-') }
    command_line_options.each do |option|
      option_key = option.sub '-', ''
      unless CLAUSES_DEF[option_key.to_sym]
        raise InvalidArguments, "options not valid: #{option}. Valid options are -s -o -f -g"
      end
    end
  end

  def self.validate_values(arguments)
    command_line_options_with_values = arguments.each_slice(2).to_a

    command_line_options_with_values.each do |clause|
      command_line_option, command_line_option_arg = clause
      command_line_option = command_line_option.sub('-', '').to_sym

      validate = CLAUSES_DEF[command_line_option][:validate]

      validate&.call(command_line_option_arg)
    end
  end

  def self.validate_arguments(string_argv)
    validate_empty_arguments(string_argv)

    arguments = string_argv.split(' ')

    validate_options(arguments)

    validate_values(arguments)
  end

  def self.file_importer
    FileImporter.new(
      path: File.expand_path('../data/file_sample.txt', __dir__),
      separator: '|'
    )
  end

  def self.create_table(data_store)
    data_store.create_table Project do |t|
      t.string :project # max 64
      t.string :shot # max 64
      t.integer :version # 0 and 65535
      t.string :status # max 32
      t.date :finish_date # YYYY-MM-DD
      t.float :internal_bid
      t.timestamp :created_date # YYYY-MM-DD HH:MM format
    end
  end

  def self.create_unique_index(data_store)
    data_store.add_index(
      Project,
      %i[project shot version],
      unique: true
    )
  end

  def self.create_store
    data_store = Store.new
    create_table(data_store)
    create_unique_index(data_store)
    data_store
  end

  def self.save_record_in_store(file_importer, data_store)
    file_importer.lines_as_hash.each do |data|
      data_store.store_record(Project, data)
    end
  end

  def self.build_query_and_run(command_line_options_with_values, data_store)
    new_query = data_store.new_query.from(Project)

    command_line_options_with_values.reduce(new_query) do |query, clause|
      command_line_option, command_line_option_arg = clause

      command_line_option = command_line_option.sub('-', '')
      clause_def = CLAUSES_DEF[command_line_option.to_sym]
      method = clause_def[:method]
      parser = clause_def[:parser]

      query.send(method.to_sym, parser.call(command_line_option_arg))
    end.run
  end

  def self.print_results(results)
    results.map do |result|
      values = result.values.map do |value|
        value.is_a?(Enumerator) ? "[#{value.to_a.join(',')}]" : value
      end
      values.join(',')
    end
  end

  def self.run(string_argv)
    validate_arguments(string_argv)

    data_store = create_store

    save_record_in_store(file_importer, data_store)

    print_results build_query_and_run(string_argv.split(' ').each_slice(2).to_a, data_store)
  end
end
