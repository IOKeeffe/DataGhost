require_relative 'assoc_options'
require_relative 'belongs_to_options'
require_relative 'has_many_options'

module Associatable
  attr_accessor :source_options, :source_table, :source_primary_key, :source_foreign_key,
                :through_options, :through_table, :through_primary_key, :through_foreign_key

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      primary_key = self.send(options.primary_key)
      model = options.class_name
      return_values = model.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      key_val = self.send(self.through_foreign_key)
      self.source_class.parse_all(join_db_tables(key_val)).first
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      key_val = self.send(self.through_foreign_key)
      self.source_class.parse_all(join_db_tables(key_val))
    end
  end

  private
  def join_db_tables
    DBConnection.execute(<<-SQL, key_val)
    SELECT
      #{self.source_table}.*
    FROM
      #{self.through_table}
    JOIN
      #{self.source_table} ON #{self.source_table}.#{self.source_primary_key} = #{self.through_table}.#{self.source_foreign_key}
    WHERE
      #{self.through_table}.#{self.through_primary_key} = ?
    SQL
  end

  def through_setup(through_name)

    @class_name = options[:class_name] ? options[:class_name] : name.to_s.camelcase.singularize

    @foreign_key = options[:foreign_key] ? options[:foreign_key] : "#{class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] ? options[:primary_key] : :id
    self.through_options = self.class.assoc_options[through_name]

    self.through_table = self.through_options.table_name
    self.through_primary_key = self.through_options.primary_key
    self.through_foreign_key = self.through_options.foreign_key
  end

  def source_setup(source_name)
    self.source_options = self.through_options.model_class.assoc_options[source_name]
    self.source_class = self.source_options.model_class

    self.source_table = self.source_options.table_name
    self.source_primary_key = self.source_options.primary_key
    self.source_foreign_key = self.source_options.foreign_key
  end
end
