require 'sqlite3'
# Initializes the database. The format to use if there are more tables
# is simple. Just create a SQL file corresponding to the table name
# and add that table to the @tables instance variable.
module AWSMine
  class DBHelper
    def initialize
      @db = SQLite3::Database.new 'minecraft.db'
      @tables = %w(ec2_db)
    end

    def table_exists?(table)
      retrieved = @db.execute <<-SQL
        SELECT name FROM sqlite_master WHERE type='table' AND name='#{table}';
      SQL
      retrieved.first.first == table unless retrieved.nil? || retrieved.empty?
    end

    def init_db
      @tables.each do |table|
        sql = File.open(File.join(__dir__,
                                  "../../cfg/#{table}.sql"),
                        'rb', &:read).chop
        @db.execute sql unless table_exists? table
      end
    end

    def instance_exists?
    end

    def store_instance(ip, id)
      @db.execute "INSERT INTO instances VALUES ('#{ip}', '#{id}');"
    end
  end
end
