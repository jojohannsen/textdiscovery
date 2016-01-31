class Review
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :text, String
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :name
  validates_presence_of :text
end