require_relative 'assoc_options'
require 'active_support/inflector'

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] ? options[:class_name] : name.to_s.camelcase.singularize

    @foreign_key = options[:foreign_key] ? options[:foreign_key] : "#{self_class_name.underscore}_id".to_sym

    @primary_key = options[:primary_key] ? options[:primary_key] : :id

  end

end
