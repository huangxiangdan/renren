# %w(sinatra haml oauth omniauth-oauth omniauth-renren openid/store/filesystem).each { |dependency| require dependency }
# enable :sessions
# 
# #use Rack::Session
# use OmniAuth::Strategies::Renren, 'bd84a1264b674b8c946c3effe1048779', '4ba014c9c2d94affad726ab99aee1b7f'
# #use OmniAuth::Strategies::Tsina, '651855687', 'a25a4d70f59a017febae753787a103ba'
# 
# get '/hi' do
#   "Hello World!"
#   session[:atoken]
#   session[:asecret]
# end
# 
# get '/connect' do
#   oauth = Renren::OAuth.new(Renren::Config.api_key, Renren::Config.api_secret)
#   consumer = oauth.consumer
#   request_token = consumer.get_request_token
#   session[:rtoken], session[:rsecret] = request_token.token, request_token.secret
#   redirect "#{request_token.authorize_url}&oauth_callback=http://#{request.env["HTTP_HOST"]}/callback"
# end
# 
# get '/callback' do
#   oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
#   oauth.authorize_from_request(session[:rtoken], session[:rsecret], params[:oauth_verifier])
#   session[:rtoken], session[:rsecret] = nil, nil
#   session[:atoken], session[:asecret] = oauth.access_token.token, oauth.access_token.secret
#   redirect "/hi"
# end
# 
# get '/auth/:name/callback' do
#   auth_hash = request.env['omniauth.auth']
# end

require 'rubygems'
require 'sinatra'
#require 'renren'
require 'omniauth-renren'
require 'renren'
#require 'oa-oauth'

use Rack::Session::Cookie
Renren::Config.api_key = "bd84a1264b674b8c946c3effe1048779"
Renren::Config.api_secret = "4ba014c9c2d94affad726ab99aee1b7f"
use OmniAuth::Builder do
  #provider :open_id, OpenID::Store::Filesystem.new('/tmp')
  provider :Renren, 'bd84a1264b674b8c946c3effe1048779', '4ba014c9c2d94affad726ab99aee1b7f'
  #provider :Tsina, '2901048510', 'c6a8cc347c5077d5889ccf275a206d99'
  #provider :Twitter, "YPEbJ2rUT4lFhZWYPCIBw", "x6xGNd2b2TGF03wAFOSEDve0i3slydKvEts0pOrUbM"
end

get '/' do
  base = Renren::Base.new("170373|6.a31f6c33c35cd855ae9faef267d99a4f.2592000.1325124000-227788459")
  puts base.call_method({:method => 'friends.get'})
end
#{"scope":"publish_feed","expires_in":2592956,"refresh_token":"170373|7.3c171a6a40ecb8b94ae048dee94967d7.5184000.1327716000-227788459","user":{"id":227788459,"name":"黄祥旦","avatar":[{"type":"avatar","url":"http:\/\/head.xiaonei.com\/photos\/0\/0\/men_head.gif"},{"type":"tiny","url":"http:\/\/head.xiaonei.com\/photos\/0\/0\/men_tiny.gif"},{"type":"main","url":"http:\/\/head.xiaonei.com\/photos\/0\/0\/men_main.gif"},{"type":"large","url":"http:\/\/head.xiaonei.com\/photos\/0\/0\/large.jpg"}]},"access_token":"170373|6.a31f6c33c35cd855ae9faef267d99a4f.2592000.1325124000-227788459"}
get '/auth/:name/callback' do
  #request.env['omniauth.auth']['credentials']['token']
  #request.env['omniauth.auth']['extra']['friends_ids'].inspect
  params = {}
  params[:api_key] = "bd84a1264b674b8c946c3effe1048779"
  params[:method] = "friends.get"
  params[:call_id] = Time.now.to_i
  params[:format] = 'json'
  params[:v] = '1.0'
  params[:uids] = request.env['omniauth.auth']['uid']
  #params[:session_key] = request.env['omniauth.auth']['credentials']['token'].split('|')[1]
  params[:access_token] = "test"#request.env['omniauth.auth']['credentials']['token']
  params[:sig] = Digest::MD5.hexdigest(params.map{|k,v| "#{k}=#{v}"}.sort.join + "4ba014c9c2d94affad726ab99aee1b7f")
  puts params.inspect
  puts request.env['omniauth.auth']['extra']['raw_info']
  # rs = Net::HTTP.post_form(URI.parse('http://api.renren.com/restserver.do'), params).body
  # puts MultiJson.decode(rs)
end


# post '/auth/:name/callback' do
#   #auth = request.env['omniauth.auth']
#   <<-HTML
#   <a href='/auth/renren'>Sign in with Renren</a>
#   
#   <form action='/auth/open_id' method='post'>
#     <input type='text' name='identifier'/>
#     <input type='submit' value='Sign in with OpenID'/>
#   </form>
#   HTML
#   # do whatever you want with the information!
# end

def get_params(method)
  params = {}
  params[:api_key] = "bd84a1264b674b8c946c3effe1048779"
  params[:method] = method
  params[:call_id] = Time.now.to_i
  params[:format] = 'json'
  params[:v] = '1.0'
  params[:uids] = request.env['omniauth.auth']['uid']
  params[:session_key] = request.env['omniauth.auth']['credentials']['token']["session_key"]
  params[:sig] = Digest::MD5.hexdigest(params.map{|k,v| "#{k}=#{v}"}.sort.join + "4ba014c9c2d94affad726ab99aee1b7f")
  params
end

def friends_ids
  @friends_ids ||= MultiJson.decode(Net::HTTP.post_form(URI.parse('http://api.renren.com/restserver.do'), get_params('friends.get')).body)[0]
  @friends_ids
rescue ::Errno::ETIMEDOUT
  raise ::Timeout::Error
end
