require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require_relative './db/connection'
require_relative './models/category'
require_relative './models/post'


after do
  ActiveRecord::Base.connection.close
end


get '/' do 

categories = Category.all
erb(:index, {locals: {categories: categories}})

end

# TO ADD A NEW CATEGORY
post '/' do 
	name= params['name']
	description = params['description']
	
	new_category=Category.create({
		name: name,
		description: description,
		upvote: 0,
		downvote: 0
		})

	redirect '/'
end

# VIEW CATEGORY PAGE
get '/category/:name' do
	cat_name = params['name']
	category = Category.find_by(name: cat_name)
	posts = Post.where({cat_name: cat_name})
	
	erb(:category, {locals: {category: category, posts: posts}})

end

#DELETE CATEGORY
delete '/category/:name' do

	cat_name = params['name']
	category = Category.find_by(name: cat_name)

	category.destroy

	redirect "/"

end

#UPVOTE CATEGORY
put '/category/:name/upvote' do

	cat_name = params['name']
	category = Category.find_by(name: cat_name)
	upvote = category.upvote
	new_upvote = upvote + 1

	category_hash={
		name: category.name, 
		description: category.description, 
		upvote: new_upvote, 
		downvote: category.downvote
	}

	category.update(category_hash)

	redirect "/category/#{category.name}"

end

#DOWNVOTE CATEGORY
put '/category/:name/downvote' do

	cat_name = params['name']
	category = Category.find_by(name: cat_name)
	downvote = category.downvote
	new_downvote = downvote + 1

	category_hash={
		name: category.name, 
		description: category.description, 
		upvote: category.upvote, 
		downvote: new_downvote
	}

	category.update(category_hash)

	redirect "/category/#{category.name}"

end

#NEW POST PAGE
get '/category/:name/post/new' do

cat_name=params['name']
category=Category.find_by(name: cat_name)


erb(:newPost, {locals: {category: category}})

end

#TO ADD NEW POST
post '/category/:name/post/new' do
	binding.pry
	title = params['title']
	content= params['content']
	url = params['url']
	author= params['author']
		category=Category.find_by(name: params['name'])
	cat_name= category.name 

	if params['expiration'] 
		expiration = true
		exp_date = Time.now
	else
		expiration = false
		exp_date = nil
	end

	if params['author'] != nil
		author= params['author']
	else
		author= 'unknown'
	end

	new_post = Post.create({
		cat_name: cat_name,
		title: title,
		content: content,
		image_url: url,
		author: author,
		upvote: 0,
		downvote: 0,
		expiration: expiration,
		exp_date: exp_date
		})

redirect "/category/#{cat_name}/post/#{new_post.id}"

end

#VIEW POST
get '/category/:name/post/:id' do

post = Post.find_by(id: params['id'])
	erb(:post, {locals: {post: post}})
end




