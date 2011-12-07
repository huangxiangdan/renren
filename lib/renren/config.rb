module Renren
  module Config
    
    def self.api_key=(val)
      @@api_key = val
    end
    
    def self.api_key
      @@api_key
    end
    
    def self.api_secret=(val)
      @@api_secret = val
    end
    
    def self.api_secret
      @@api_secret
    end

  end
end