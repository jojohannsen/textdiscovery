require 'sinatra'
require 'sinatra/json'
require 'bundler'

Bundler.require
require_relative 'lib/review'
require_relative 'suffix_tree/data/word_data_source'
require_relative 'suffix_tree/suffix_tree'
require_relative 'suffix_tree/search/searcher'

DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.finalize
DataMapper.auto_migrate!

get "/" do
  current_time = "the current time is <%= Time.now %>"
  erb current_time
end

get '/form' do
  erb :form
end

get '/bootstrap' do
  erb :bootstrap
end

get '/bootstrap2' do
  erb :bootstrap2
end

get '/starter' do
  if !defined?(@@documentLoaded)
    @@documentLoaded = false
  end
  @documentLoaded = @@documentLoaded
  if (@documentLoaded)
    @documentName = @@documentName
  end
  erb :starter
end

get '/load' do
  content_type :json

  @@dataSource = WordDataSource.new("data/hadoopBook.txt")
  hash = {
      :valueDepth => true
  }
  @@suffixTree = SuffixTree.new(nil, hash)
  @@suffixTree.addDataSource(@@dataSource)
  @@documentName = "hadoopBook.pdf"
  result = { "file" => @@documentName, "numberWords" => @@suffixTree.startOffset }
  @@documentLoaded = true
  status 200
  json result
end

post '/searcher' do
  content_type :json

  searcher = Searcher.new(@@dataSource, @@suffixTree.root)
  print "Params[:words] is #{params[:words]}\n"
  words = params[:words]
  result = []
  words.each do |word|
      result <<= searcher.findWord(word)
  end
  status 200
  json result.to_s
end

get '/search/:word' do
  content_type :json
  searcher = Searcher.new(@@dataSource, @@suffixTree.root)
  result = searcher.findWord(params[:word])
  hash = { params[:word] => result }
  status 200
  json hash.to_s
end

get '/reviews' do
  content_type :json

  reviews = Review.all
  reviews.to_json
end

get '/reviews/:id' do
  content_type :json

  review = Review.get params[:id]
  review.to_json
end

post '/reviews' do
  content_type :json

  review = Review.new params[:review]
  if review.save then
    status 201
  else
    status 500
    json review.errors.full_messages
  end
end

put '/reviews/:id' do
  content_type :json

  review = Review.get params[:id]
  if review.update params[:review]
    status 200
    json "Review was updated."
  else
    status 500
    json review.errors.full_messages
  end
end

delete '/reviews/:id' do
  content_type :json

  review = Review.get params[:id]
  if review.destroy
    status 200
    json "Review was removed."
  else
    status 500
    json "There was a problem removing the review"
  end
end
