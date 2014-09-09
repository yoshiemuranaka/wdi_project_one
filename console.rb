require_relative './db/connection'
require_relative './models/category'
require_relative './models/post'
require_relative './models/comment'
# require 'sendgrid'
# require 'sendgrid-ruby'
#require 'sendgrid_ruby'
require 'twilio-ruby'
require 'pry'
require 'sinatra'
require_relative './models/catSubscriber'
binding.pry

# account_sid = "AC58b51516f7b7913f72dc347ae7031497"
# auth_token = "9c3f43ed9339d26d0b29fb63c9741651"
# client = Twilio::REST::Client.new account_sid, auth_token

# from ="+13234552057"

# client.account.messages.create(:from => from, 
# 							   :to => "+16263405619",
# 							   :body => "herro")

# puts "sent Message"

# class UserNotifier < ActionMailer::Base
#   default :from => 'any_from_address@example.com'
#   # send a signup email to the user, pass in the user object that   contains the user's email address
#   def send_signup_email(user)
#     @user = user
#     mail( :to => @user.email,
#     :subject => 'Thanks for signing up for our amazing app' )
#   end
# end

# ActionMailer::Base.smtp_settings = {
#   :user_name => 'yoshiemuranaka',
#   :password => 'Maxth3cat!',
#   :address => 'smtp.sendgrid.net',
#   :port => 587,
#   :authentication => :plain,
#   :enable_starttls_auto => true
# }





#client = Sendgrid::Client.new(api_user: 'yoshiemuranaka', api_key: 'Maxth3cat!')

