require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    # ...
  end
end

class SQLObject
  self.keys.map { |key| "#{key} = ?" }
end
