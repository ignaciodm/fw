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
          FilterExpressionParse.new(str)
              end
    },
    g: {
      method: 'group_by',
      parser: proc do |str| str.downcase.split(',') end
    }
  }.freeze

  def self.build_argv_as_hash(string_argv)
    string_argv
      .split(' -')
      .delete_if(&:empty?)
      .map do |arg|
        command_line_option = arg.slice(0)   # "f PROJECT=\"the hobbit\" OR PROJECT=\"lotr\"" -> "f"
        command_line_option_arg = arg[2..-1].rstrip # "f PROJECT=\"the hobbit\" OR PROJECT=\"lotr\"" -> "PROJECT=\"the hobbit\" OR PROJECT=\"lotr\""
        {key: command_line_option.to_sym, value:  command_line_option_arg}
      end
  end

  def self.validate_empty_arguments(string_argv)
    return unless string_argv.empty?

    raise InvalidArguments, File.read(File.expand_path('../data/how_to_use.txt', __dir__))
  end

  def self.validate_options(argv_as_hash)
    argv_as_hash.each do |option|
      unless CLAUSES_DEF[option[:key].to_sym]
        raise InvalidArguments, "options not valid: #{option[:key]}. Valid options are -s -o -f -g"
      end
    end
  end

  def self.validate_values(argv_as_hash)
    argv_as_hash.each do |option|
      validate = CLAUSES_DEF[option[:key]][:validate]
      validate&.call(option[:value])
    end
  end

  def self.validate_arguments(argv_as_hash)
    validate_options(argv_as_hash)
    validate_values(argv_as_hash)
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

  def self.build_query_and_run(argv_as_hash, data_store)
    new_query = data_store.new_query.from(Project)

    argv_as_hash.reduce(new_query) do |query, argument_hash|
      command_line_option = argument_hash[:key]  # "f PROJECT=\"the hobbit\" OR PROJECT=\"lotr\"" -> "f"
      command_line_option_arg = argument_hash[:value]  # "f PROJECT=\"the hobbit\" OR PROJECT=\"lotr\"" -> "PROJECT=\"the hobbit\" OR PROJECT=\"lotr\""

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
    validate_empty_arguments(string_argv)

    argv_as_hash = build_argv_as_hash(string_argv)

    puts argv_as_hash
    validate_arguments(argv_as_hash)

    data_store = create_store

    save_record_in_store(file_importer, data_store)

    print_results build_query_and_run(argv_as_hash, data_store)
  end
end
