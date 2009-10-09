# This file represents the Model in the MVC pattern.
#
# The file will be loaded into MagLev as an MDB Model for the Database
# named 'post' (see Rakefile mdb:create).  The class methods in Post will
# be available to the Sinatra client app as views from the MDB::Server.
#
# == TODO
#
# * Should each data item know their own id?  We could mixin support for
#   adding an id field.
#
class Post
  attr_reader :text, :title, :timestamp, :tags

  def initialize(params)
    # TODO: Here we see an opportunity to add ActiveRecord style
    # validations and default values. OTOH, perhaps its more typing to add
    # the validations etc. than to just hard code it the old way?
    @title = params[:title]                      # must_not_be_nil
    @text =  params[:text]                       # must_not_be_nil
    @timestamp = params[:timestamp] || Time.now  # defaults
    @tags = params[:tags] || []                  # defaults
  end

  # Tag the post: (a) adds reciever to the tag and (b) adds
  # each tag to recevier's @tags
  def tag(*tags)
    tags.each do |tag|
      tag << self
      @tags << tag
    end
  end

  # MDB::Database calls this whenever a document is added
  def document_added(document)
    # Update the list of recent posts (saves searching)
    @recent_posts ||= []
    @recent_posts << document
    @recent_posts.shift if @recent_posts.size > 5
  end

  #############################################
  #  VIEWS
  #############################################

  FIVE_DAYS = 5 * 60 * 60 * 24 # Number of seconds in five days

  # This is a view method.  It will be invoked by the client app by sending
  # Data will be a collection of posts that the database gives us.
  def self.recent(data)
    cutoff = Time.now - FIVE_DAYS
    recent = data.select { |k,v| v.timestamp > cutoff }
    recent[0..5].map { |x| x[1] }
  end

  #############################################
  # Stuff to be injected by the database
  #############################################
  class << self
    attr_reader :database
    def set_db(database)
      @database = database
    end
  end
end

class Tag < Array
  attr_reader :name

  def initialize(name)
    @name = name.to_s
  end

  def to_s
    @name
  end

  def self.find_by_name(name)
    Tag.detect { |t| t.name == name }
  end
end
