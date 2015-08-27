require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect '/movies'
end

# Show a table of movies, sort alphabetically
get '/movies' do
  movie_list = []
  db_connection do |conn|
    movie_list = conn.exec('SELECT movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio, movies.id FROM movies JOIN genres ON movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id ORDER BY movies.title')
  end
  erb :'movies/index', locals: { movie_list: movie_list}
end

# Show details for a movie
get '/movies/:id' do
  movie_info = []
  cast_info = []
  db_connection do |conn|
    movie_info = conn.exec('SELECT movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio FROM movies JOIN genres ON movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id WHERE movies.id = $1 ORDER BY movies.title',[params[:id]])
    cast_info = conn.exec('SELECT actors.name, cast_members.character, actors.id FROM movies JOIN cast_members ON movies.id = cast_members.movie_id JOIN actors ON actors.id = cast_members.actor_id WHERE movies.id = $1',[params[:id]])
    # binding.pry
  end
  erb :'movies/show', locals: {movie_info: movie_info[0], cast_list: cast_info}
end

#Show list of actors, sort alphabetically
get '/actors' do
  actors=[]
  db_connection do |conn|
    actors = conn.exec('SELECT name, id FROM actors ORDER BY name')
  end
  erb :'actors/index', locals: {actors: actors}
end

# Show details for actors
get '/actors/:id' do
  actor_info = []
  db_connection do |conn|
    actor_info = conn.exec('SELECT actors.name, cast_members.character, movies.title, movies.id AS movie_id FROM movies JOIN cast_members ON movies.id = cast_members.movie_id JOIN actors ON actors.id = cast_members.actor_id WHERE actors.id = $1',[params[:id]])
  end
  erb :'actors/show', locals: {actor_info: actor_info}
end
