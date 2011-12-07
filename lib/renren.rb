# code is an adaptation of the twitter gem by John Nunemaker
# http://github.com/jnunemaker/twitter
# Copyright (c) 2009 John Nunemaker
#
# made to work with china's facebook, 人人网

require 'renren/config'
require 'renren/base'
if File.exists?('config/weibo.yml')
  weibo_oauth = YAML.load_file('config/weibo.yml')[Rails.env || env || 'development']
  Weibo::Config.api_key = weibo_oauth["api_key"]
  Weibo::Config.api_secret = weibo_oauth["api_secret"]
end