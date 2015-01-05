require 'sinatra'
require 'sinatra/reloader' if development?
require 'sass'
require 'slim'
require './song'


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

configure do
  enable :sessions
  set :username, 'frank' 
  set :password, 'sinatra'
end

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end
configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
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

get '/contact' do
	erb :contact
end

get '/songs' do
	@songs = Song.all
	erb :songs
end

get '/songs/new' do
  halt(401,'Not Authorized') unless session[:admin]
  @song = Song.new
  slim :new_song
end

get '/songs/:id' do
	@song = Song.get(params[:id])
	slim :show_song
end

get '/songs/:id/edit' do
  @song = Song.get(params[:id])
  slim :edit_song
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
  
end


