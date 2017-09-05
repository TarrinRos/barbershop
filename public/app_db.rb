require 'sqlite3'

db = SQLite3::Database.new 'barbershop.db'
db.results_as_hash = true

# db.execute 'select * from Users' do |row|
#   returns array
#   puts "#{row[1]} записался на #{row[4]}"
#   puts '==========='
# end

db.execute 'select * from Users' do |row|
  # returns information by the key
  puts "#{row['first_name']} записался на #{row['date_stamp']}"
  puts '==========='
end
