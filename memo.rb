# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

file_path = 'public/memos.json'

def get_memos(file_path)
  File.open(file_path) { |file| JSON.parse(file.read) }
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = get_memos(file_path)
  erb :index
end

get '/memos/new' do
  erb :new
end

get '/memos/:id' do
  memos = get_memos(file_path)
  memo = memos[params[:id].to_s]
  if memo
    @title = memo['title']
    @content = memo['content']
    erb :show
  else
    status 404
    "Memo with ID #{params[:id]} not found"
  end
end

def set_memos(file_path, memos)
  File.open(file_path, 'w') { |file| JSON.dump(memos, file) }
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  memos = get_memos(FILE_PATH)
  id = (memos.keys.map(&:to_i).max + 1).to_s
  memos[id] = { 'title' => title, 'content' => content }
  set_memos(FILE_PATH, memos)
  redirect '/memos'
end

get '/memos/:id/edit' do
  memos = get_memos(file_path)
  @title = memos[params[:id]]['title']
  @content = memos[params[:id]]['content']
  erb :edit
end

patch '/memos/:id' do
  title = params[:title]
  content = params[:content]
  memos = get_memos(file_path)
  memos[params[:id]] = { 'title' => title, 'content' => content }
  set_memos(file_path, memos)
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memos = get_memos(file_path)
  memos.delete(params[:id])
  set_memos(file_path, memos)
  redirect '/memos'
end
