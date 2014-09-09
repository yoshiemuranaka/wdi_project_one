require_relative './db/connection'
require_relative './models/category'
require_relative './models/post'
require_relative './models/comment'
require_relative './models/catSubscriber'
require_relative './models/postSubscriber'


after do
  ActiveRecord::Base.connection.close
end


get '/' do

## SETTING BROWSE BY CONDITIONAL
if params['browse'] 
	if params['browse'] == 'votes'
		posts = Post.paginate(:page => params[:page], :per_page => 2).order('upvote DESC')
	elsif params['browse'] == 'comments'
		posts = Post.paginate(:page => params[:page], :per_page => 2).order('comments DESC')
	else
		posts = Post.paginate(:page => params[:page], :per_page => 2).order('upvote DESC')
	end

else
	posts = Post.paginate(:page => params[:page], :per_page => 2).order('upvote DESC')
end
##

categories = Category.all.order(upvote: :desc)
erb(:index, {locals: {categories: categories, posts: posts}})

end

# TO ADD A NEW CATEGORY
post '/' do 
	name= params['name'].downcase
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
	posts = Post.where({cat_name: cat_name}).paginate(:page => params['page'], :per_page => 2).order('created_at DESC')
	categories =Category.all
	categories=categories.order(upvote: :desc)
	
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
categories = Category.all.order(upvote: :desc)

erb(:newPost, {locals: {category: category, categories: categories}})

end

#TO ADD NEW POST
post '/category/:name/post/new' do
#binding.pry
	title = params['title']
	content= params['content']
	url = params['url']
	author= params['author']
		category=Category.find_by(name: params['name'])
	cat_name= category.name 
	#SETS EXPIRATION BOOLEAN IN POST TABLE
	if params['expiration'] != '0'
		expiration = true
		exp_date = Time.now + params['expiration'].to_i
	else
		expiration = false
		exp_date = Time.now
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
		exp_date: exp_date,
		comments: 0,
		})

### SENDING SUBSCRIBERS TEXT UPDATE ABOUT NEW POST
account_sid = "AC58b51516f7b7913f72dc347ae7031497"
auth_token = "9c3f43ed9339d26d0b29fb63c9741651"
client = Twilio::REST::Client.new account_sid, auth_token

from ="+13234552057"

subscribers = CatSubscriber.where({cat_name: cat_name})

subscribers.each do |subscriber|
	client.account.messages.create(:from => from, 
								   :to => subscriber.phone,
								   :body => "New post for #{cat_name}: #{title}, #{content[0..10]}...")
end
###

redirect "/category/#{cat_name}/post/#{new_post.id}"

end

#VIEW POST
get '/category/:name/post/:id' do

	cat_name=params['name']
	posts = Post.where({cat_name: cat_name}).order(upvote: :desc)
	category = Category.find_by(name: cat_name)
	post = Post.find_by(id: params['id'])
	categories = Category.all.order(upvote: :desc)
	post_id=params['id']
	comments=Comment.where({post_id: post_id}).order(created_at: :desc)
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

#POST NEW COMMENT
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


	post=Post.find_by(id: post_id)
	comments = post.comments + 1
	post.update({comments: comments})

### SENDING SUBSCRIBERS TEXT UPDATE ABOUT COMMENTS ON POST
account_sid = "AC58b51516f7b7913f72dc347ae7031497"
auth_token = "9c3f43ed9339d26d0b29fb63c9741651"
client = Twilio::REST::Client.new account_sid, auth_token

from ="+13234552057"

subscribers = PostSubscriber.where({post_id: post_id})

subscribers.each do |subscriber|
	client.account.messages.create(:from => from, 
								   :to => subscriber.phone,
								   :body => "New comment on #{title}: '#{comment[0..10]}...'")
end
###

	redirect "/category/#{cat_name}/post/#{post_id}"

end

#SUBSCRIBE TO A CATEGORY

post '/category/:name/subscribe' do

	cat_name=params['name']
	area_code=params['phone'].split('-')[0]
	number=params['phone'].split('-')[1]
	phone= '+1' + area_code + number

	CatSubscriber.create({
		cat_name: cat_name,
		phone: phone
		})
	
	categories = Category.all.order(upvote: :desc)
	erb(:subscribed, {locals: {categories: categories}})

end

post '/category/:name/post/:id/subscribe' do

	post_id = params['id']
	area_code=params['phone'].split('-')[0]
	number=params['phone'].split('-')[1]
	phone= '+1' + area_code + number

	PostSubscriber.create({
		post_id: post_id,
		phone: phone
		})

	categories = Category.all.order(upvote: :desc)
	erb(:subscribed, {locals: {categories: categories}})

end










