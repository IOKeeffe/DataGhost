require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'
module Searchable
  def where(params)
    where_string = []
    value_string = []
    params.map do |attribute, value|
      where_string << "#{attribute} = ?"
      value_string << value
    end
    where_string = where_string.join(" AND ")

    found_rows = DBConnection.execute(<<-SQL, value_string)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
      SQL
    return [] if found_rows.length == 0
    found_rows.map do |found_row|
      self.new(found_row)
    end
  end
end

class SQLObject
  extend Searchable
end
