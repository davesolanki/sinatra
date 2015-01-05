require 'dm-core'
require 'dm-migrations'
require 'sinatra/flash'

class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :lyrics, Text
  property :length, Integer
  property :released_on, Date
  def released_on=date
    super Date.strptime(date, '%m/%d/%Y')
  end 
end

DataMapper.finalize

module SongHelpers
  def find_songs
    @songs = Song.all
  end
  def find_song
    Song.get(params[:id])
end
  def create_song
    @song = Song.create(params[:song])
  end 
end

helpers SongHelpers



get '/songs/:id/edit' do
  @song = find_song
  erb :edit_song
end

put '/songs/:id' do
  song = find_song
  if song.update(params[:song])
    flash[:notice] = "Song successfully updated"
  end
  redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
  find_song.destroy
  redirect to('/songs')
#  if find_song.destroy
#    flash[:notice] = "Song deleted"
#  end
end

get '/songs/new' do
  halt(401,'Not Authorized') unless session[:admin]
  @song = Song.new
  erb :new_song
end

get '/songs/:id' do
  song = find_song
  @song = song
  erb :show_song
#   if song.update(params[:song])
#    flash[:notice] = "Song successfully updated"
#   end
end

get '/songs/:id/edit' do
  @song = find_song
  erb :edit_song
end

post '/songs' do
  flash[:notice] = "Song successfully added" if create_song
  redirect to("/songs/#{@song.id}")
end
