require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require_relative './db/connection'
require_relative './models/category'
require_relative './models/post'
require_relative './models/comment'


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
	categories =Category.all
	
	erb(:category, {locals: {category: category, posts: posts, categories: categories}})

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

	category.update({upvote: new_upvote})

	redirect "/category/#{category.name}"

end

#DOWNVOTE CATEGORY
put '/category/:name/downvote' do

	cat_name = params['name']
	category = Category.find_by(name: cat_name)
	downvote = category.downvote
	new_downvote = downvote + 1

	category.update({downvote: new_downvote})

	redirect "/category/#{category.name}"

end

#NEW POST PAGE
get '/category/:name/post/new' do

cat_name=params['name']
category=Category.find_by(name: cat_name)
categories = Category.all

erb(:newPost, {locals: {category: category, categories: categories}})

end

#TO ADD NEW POST
post '/category/:name/post/new' do

	title = params['title']
	content= params['content']
	url = params['url']
	author= params['author']
		category=Category.find_by(name: params['name'])
	cat_name= category.name 
	#SETS EXPIRATION BOOLEAN IN POST TABLE
	if params['expiration'] 
		expiration = true
		exp_date = Time.now #####ADD PROPER EXP DATE
	else
		expiration = false
		exp_date = nil
	end
	#SETS AUTHOR IN POST TABLE
	if params['author'] != ''
		author= params['author']
	else
		author= "Anonymous"
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

	cat_name=params['name']
	posts = Post.where({cat_name: cat_name})
	category = Category.find_by(name: cat_name)
	post = Post.find_by(id: params['id'])
	categories = Category.all
	post_id=params['id']
	comments=Comment.where({post_id: post_id})
	
	erb(:post, {locals: {post: post, posts: posts, category: category, categories: categories, comments: comments}})
end

#POST UPVOTE
put '/category/:name/post/:id/upvote' do

	post_id=params['id']
	post=Post.find_by(id: post_id)
	upvote = post.upvote
	new_upvote = upvote + 1

	post.update({upvote: new_upvote})

	redirect "/category/#{post.cat_name}/post/#{post_id}"

end


#POST DOWNVOTE
put '/category/:name/post/:id/downvote' do

	post_id=params['id']
	post=Post.find_by(id: post_id)
	downvote = post.downvote
	new_downvote = downvote + 1

	post.update({downvote: new_downvote})

	redirect "/category/#{post.cat_name}/post/#{post_id}"

end


post '/category/:name/post/:id/comment' do

	post_id=params['id']
	cat_name=params['name']
	title=params['title']
	author=params['author']
	comment=params['comment']

	Comment.create({
		post_id: post_id,
		cat_name: cat_name,
		title: title,
		content: comment,
		author: author
		})

	redirect "/category/#{cat_name}/post/#{post_id}"


end




