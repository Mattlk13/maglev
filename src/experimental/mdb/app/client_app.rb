require 'rubygems'
require 'sinatra'
require 'mdb/client'

# The BlogApp implements the View and Controller parts of the MVC
# pattern.  This app receives end user http requests, invokes a model
# method (through a "view"), and then renders the appropriate view from the
# model data.
#
# The data returned by the model is JSON.
#
# Run by MRI
# Listens on port 3333
# Contacts MDB on port 4567
#
#
=begin

    |------+------------+-----------------------+----------|
    | Verb | Route      | Action                | View     |
    |------+------------+-----------------------+----------|
    | GET  | /          | redirect              | N/A      |
    | GET  | /posts     | List recent posts     | :index   |
    | GET  | /posts/new | Show new post form    | :newpost |
    | POST | /posts     | Create post from data | :show    |
    | GET  | /posts/:id | Show post with id     | :show    |
    | PUT  | /posts/:id | Update post from data | :show    |
    |------+------------+-----------------------+----------|

=end

class BlogApp < Sinatra::Base
  set :app_file, File.dirname(__FILE__)
  set :static, true

  SERVER  = 'http://localhost:4567'
  POSTS_DB = 'theBlogPosts'
  TAGS_DB  = 'theBlogTags'

  def initialize(*args)
    super
    @server = MDB::RESTServer.new SERVER
    @posts_db = @server[POSTS_DB]
    @tags_db  = @server[TAGS_DB]
    puts "-- @posts_db: #{@posts_db}"
    puts "-- @tags_db:  #{@tags_db}"
    @title = "MRI Blog Using MagLevDB"
    @nav_bar =  <<-EOS
        <ul class="menu">
          <li><a href="/">Home</a></li>
          <li><a href="/posts/new">New Post</a></li>
        </ul>
    EOS
  end

  get '/' do
    redirect '/posts'
  end

  get '/posts' do
    @posts = @posts_db.execute_view(:recent)
    erb :home
  end

  # Display a form to create a new blog post
  #
  # This route must go before /posts/:id, otherwise /posts/new matches
  # /posts/:id and we try to find a db named 'new'
  get '/posts/new' do
    erb :newpost
  end

  get '/posts/:id' do
    json = data_for("/posts/#{params[:id]}")
    @post = JSON.parse(json)
    erb :post
  end

  # Create a new blog post
  # Submitting a /posts/new form goes here.
  # On success, redirects to show
  post '/posts' do
    new_params = {
      :title => params[:title],
      :text => params[:text],
      :tags => params[:tags]
    }
    response = put_to(new_params, '/posts')

    case response.status
    when 200..299
      id = JSON.parse response.content
      redirect "/posts/#{id}"
    when 300..399
      halt 404, "Can't redirect to server:  Server response #{response.status}"
    else
      halt response.status,
           "MDB Server: #{response.status}: #{response.content}"
    end
  end

end

BlogApp.run!   :host  => 'localhost', :port => 3333
