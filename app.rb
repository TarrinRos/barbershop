# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

get '/' do
  erb 'Hello! <a href="https://github.com/bootstrap-ruby/sinatra-bootstrap">Original</a> pattern has been modified for <a href="http://rubyschool.us/">Ruby School</a>!!!'
end

get '/about' do
  erb :about
end

get '/visit' do
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
  # Write to users.txt
  f = File.open './public/users.txt', 'a'
  f.puts "Имя: #{@first_name}, Фамилия: #{@surname}, Номер телефона #{@phone}, Время посещения: #{@date_time}, Мастер: #{@barber_master}, Цвет: #{@colorpicker}"
  f.close
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
    @userstxt = SQLite3::Database.new './public/tar_first_db.sqlite'
    erb :admin_panel
  else
    @error = 'Вы ввели не правильное имя или пароль'
    erb :login_form
  end
end
