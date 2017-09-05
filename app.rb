# encoding: utf-8

# required gems
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

# creates database with initialization
def get_db
  db = SQLite3::Database.new './public/barbershop.db'
  db.results_as_hash = true
  return db
end

configure do
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS "Users" (
    "id"         INTEGER PRIMARY KEY AUTOINCREMENT,
    "first_name" TEXT,
    "surname"    TEXT,
    "phone"      TEXT,
    "date_stamp" TEXT,
    "barber"     TEXT,
    "color"      TEXT
)'
  db.execute 'CREATE TABLE IF NOT EXISTS "Barbers" (
    "id"            INTEGER PRIMARY KEY AUTOINCREMENT,
    "barber_name"   TEXT UNIQUE
  )'
  db.execute 'INSERT OR IGNORE INTO "Barbers"(barber_name) VALUES (
    "Edik Rukinozhnisyan"),
    ("Fedor Crugerov"),
    ("Maxim Krikov")'
end

get '/' do
  erb 'Hello! <a href="https://github.com/bootstrap-ruby/sinatra-bootstrap">Original</a> pattern has been modified for <a href="http://rubyschool.us/">Ruby School</a>!!!'
end

get '/about' do
  erb :about
end

get '/visit' do
  @barbers = get_db
  erb :visit
end

get '/contacts' do
  erb :contacts
end

get '/after_visit' do
  erb :after_visit
end

get '/after_send' do
  erb :after_send
end

get '/login/form' do
  erb :login_form
end

get '/logout' do
  erb :logout
end

get '/admin_panel' do
  erb :login_form
end

post '/visit' do
  @first_name = params[:first_name]
  @surname = params[:surname]
  @phone = params[:phone]
  @date_time = params[:date_time]
  @barber_master = params[:barber_master]
  @colorpicker = params[:colorpicker]
  @after_visit = "Спасибо #{@username}, что Вы к нам записались"


  # Validating empty input
  # HASH (with a 'new 1.9 syntax')
  hh = { first_name: 'Введите имя',
         surname: 'Введите фамилию',
         phone: 'Введите номер телефона',
         date_time: 'Введите время записи' }

  @error = hh.select { |key, _value| params[key] == '' }.values.join(', ')
  return erb :visit if @error != ''
  # saving to data_base
  db = get_db
  db.execute 'insert into "Users" (first_name, surname, phone, date_stamp, barber, color) values ( ?, ?, ?, ?, ?, ?)', [@first_name, @surname, @phone, @date_time, @barber_master, @colorpicker]

  erb :after_visit
end

post '/contacts' do
  @usrname = params[:usrname]
  @email = params[:email]
  @message = params[:message]
  @after_send = 'Спасибо Вам, за Ваше сообщение.'

  hh = { usrname: 'Вы не ввели свое имя',
         email: 'Вы не ввели Ваш email',
         message: 'Вы не написали нам сообщение' }
  @error = hh.select { |key, _value| params[key] == '' }.values.join(', ')
  return erb :contacts if @error != ''
  # save local_copy message to contacts.txt
  f = File.open './public/contacts.txt', 'a'
  f.puts "Имя: #{@usrname}, Почта: #{@email}, Сообщения: #{@message}"
  f.close
  # send copy message to admins email
  # Hash of sending params
  Pony.mail(body: "Имя: #{@usrname}, Почта: #{@email}, Сообщения: #{@message}",
            to: 'tarindis@gmail.com',
            #  subject: params[:name] + 'has contacted you.',
            via: :smtp,
            via_options: {
              address: 'smtp.gmail.com',
              port: '465',
              user_name: 'tarlocaltest',
              password: 'narn1983',
              authentication: :plain, # :plain, :login, :cram_md5, no auth by default
              domain: '127.0.0.1' # the HELO domain provided by the client to the server
            })

  erb :after_send
end

post '/admin_panel' do
  @username = params[:username]
  @password = params[:password]

  if @username == 'admin' && @password == 'narn'
    @log_name = @username
    db = get_db
    db.execute 'select * from Users order by id desc' do |row|
      @row = row
    end
    erb :admin_panel
  else
    @error = 'Вы ввели не правильное имя или пароль'
    erb :login_form
  end
end
