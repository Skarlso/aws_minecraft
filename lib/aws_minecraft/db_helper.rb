require 'sqlite3'
module AWSMine
  # Initializes the database. The format to use if there are more tables
  # is simple. Just create a SQL file corresponding to the table name
  # and add that table to the @tables instance variable.
  class DBHelper
    def initialize
      @db = SQLite3::Database.new 'minecraft.db'
      @tables = %w(instances)
    end

    def table_exists?(table)
      retrieved = @db.execute <<-SQL
        SELECT name FROM sqlite_master WHERE type='table' AND name='#{table}';
      SQL
      return false if retrieved.nil? || retrieved.empty?
      retrieved.first.first == table
    end

    def init_db
      @tables.each do |table|
        sql = File.read(File.join(__dir__, "../../cfg/#{table}.sql"))
        @db.execute sql unless table_exists? table
      end
    end

    def instance_details
      @db.execute('SELECT ip, id FROM instances;').first
    end

    def instance_exists?
      !@db.execute('SELECT id FROM instances;').empty?
    end

    def store_instance(ip, id)
      @db.execute "INSERT INTO instances VALUES ('#{ip}', '#{id}');"
    end

    def update_instance(ip, id)
      @db.execute "UPDATE instances SET ip='#{ip}' WHERE id='#{id}';"
    end

    def remove_instance
      @db.execute 'DELETE FROM instances;'
    end
  end
end
