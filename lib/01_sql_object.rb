require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

class SQLObject

  def self.all
    objects ||= DBConnection.execute(<<-SQL)
    SELECT
    #{table_name}.*
    FROM
    #{table_name}
    SQL
    self.finalize!
    self.parse_all(objects)
  end

  def self.columns
  if @columns.nil?
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    @columns = @columns.first.map(&:to_sym)
  end
  @columns
  end

  def self.finalize!
    this_table = self
    columns.each do |column|
      define_method(column) do
        return attributes[column]
      end

      define_method("#{column}=") do |input|
        attributes[column]=input
      end
    end
  end

  def self.find(id)
    attributes = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      id = #{id}
    SQL
    return nil if attributes.first.nil?
    self.new(attributes.first)
  end

  def self.find_by(search_hash)
    where_string = search_hash.keys.map do |key|
      "#{key} = #{search_hash[key]}"
    end
    where_string = where_string.join(" AND ")

    attributes = DBConnection.execute(<<-SQL, where_string)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      ?
    SQL
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.table_name=(table_name)
    self.instance_variable_set(:@table_name, table_name)
  end

  def self.table_name
    if self.instance_variable_get(:@table_name).nil?
      self.instance_variable_set(:@table_name, "#{self.name}".tableize)
    end
    self.instance_variable_get(:@table_name)
  end

  def attributes
    @attributes ||= { }
    @attributes
  end

  def attribute_values
    this_class.columns.map do |column|
      attributes[column]
    end
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless this_class.columns.include?(attr_name)
      send("#{attr_name}=", value)
    end
  end


  def insert
    column_string = this_class.columns.join(", ")
    question_marks = []
    this_class.columns.length.times do
      question_marks << "?"
    end
    question_marks = question_marks.join(", ")
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{this_class.table_name} (#{column_string})
      VALUES
        (#{question_marks})
    SQL
    attributes[:id] = DBConnection.last_insert_row_id
  end

  def method_missing(method_name, *args, &block)
    if method_name.start_with?("find_by")
      search_columns = method_name[("find_by".length)..-1].split("and")

      self.find_by(Hash[search_columns.zip(args)])
    end
  end

  def save
    id.nil? ? insert : update
  end

  def this_class
    self.class
  end

  def update
    set_string = []
    this_class.columns.length.times do |i|
      set_string << "#{this_class.columns[i]} = ?"
    end
    set_string = set_string.join(", ")

    attributes.each do |attribute, value|
      DBConnection.execute(<<-SQL, attribute_values)
        UPDATE
          #{this_class.table_name}
        SET
          #{set_string}
        WHERE
          id = #{id}
        SQL
    end
  end

end
