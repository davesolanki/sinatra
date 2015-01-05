require 'sinatra'
require 'sinatra/reloader' if development?
require 'sass'
require 'slim'
require 'pony'
require './song'


before do
  set_title
end

configure do
  enable :sessions
  set :username, 'frank' 
  set :password, 'sinatra'
end

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  set :email_address => 'smtp.gmail.com',
      :email_user_name => 'daz',
      :email_password => 'secret',
      :email_domain => 'localhost.localdomain'
end
configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  set :email_address => 'smtp.sendgrid.net',
      :email_user_name => ENV['SENDGRID_USERNAME'],
      :email_password => ENV['SENDGRID_PASSWORD'],
      :email_domain => 'heroku.com'
end

get '/environment' do
  if development?
    "development"
  elsif production?
    "production"
  elsif test?
  "test" 
  else
  "Who knows what environment you're in!"
  end
end

get '/login' do
  slim :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password 
  	 session[:admin] = true 
  	 redirect to('/songs')  
  else
    slim :login
  end 
end

get '/contact' do
  erb :contact
end

post '/contact' do
  send_message
  flash[:notice] = "Thank you for your message. We'll be in touch soon."
  redirect to('/')
end

get '/logout' do
  session.clear
  redirect to('/login')
end

get '/set/:name' do
  session[:name] = params[:name]
end

get '/get/hello' do
  "Hello #{session[:name]}"
end

get('/output.css'){ scss :stylesheet }

get '/' do
 redirect '/login' unless session[:admin] = true 
 erb :home
end

get '/about' do
	@title = "All About This Website"
	erb :about
end


get '/songs' do
	@songs = Song.all
	erb :songs
end

#---------------------------------------------------------

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />" end.join
  end 

  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end

  def set_title
  @title ||= "Songs By Sinatra"
  end


  def send_message
  Pony.mail(
  :from => params[:name] + "<" + params[:email] + ">", 
  :to => 'daz@gmail.com',
  :subject => params[:name] + " has contacted you", 
  :body => params[:message],
  :port => '587',
  :via => :smtp,
  :via_options => {
    :address => 'smtp.gmail.com', 
    :port => '587', 
    :enable_starttls_auto => true,
    :user_name => 'daz',
    :password => 'secret',
    :authentication => :plain,
    :domain => 'localhost.localdomain'
}) end
end


#----------------------------------------------------------
