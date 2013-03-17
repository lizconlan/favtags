module TwitterAuth
  module OauthUser
    def self.included(base)
      base.class_eval do
        attr_protected :access_token, :access_secret
      end

      base.extend TwitterAuth::OauthUser::ClassMethods
    end
    
    module ClassMethods
      def handle_response(response)
        case response
        when Net::HTTPOK 
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            response.body
          end
        when Net::HTTPUnauthorized
          raise 'The credentials provided did not authorize the user.'
        else
          raise response.inspect
          message = begin
            JSON.parse(response.body)['error']
          rescue JSON::ParserError
            if match = response.body.match(/<error>(.*)<\/error>/)
              match[1]
            else
              'An error occurred processing your Twitter request.'
            end
          end

          raise message
        end
      end
      
      def identify_or_create_from_access_token(token, secret=nil)
        raise ArgumentError, 'Must authenticate with an OAuth::AccessToken or the string access token and secret.' unless (token && secret) || token.is_a?(OAuth::AccessToken)
        
        token = OAuth::AccessToken.new(TwitterAuth.consumer, token, secret) unless token.is_a?(OAuth::AccessToken)
        
        response = token.get("https://api.twitter.com" + '/1.1/account/verify_credentials.json')
        user_info = handle_response(response)
        
        if user = User.find_by_twitter_id(user_info['id'].to_s)
          user.login = user_info['screen_name']
          user.assign_twitter_attributes(user_info)
          user.access_token = token.token
          user.access_secret = token.secret
          user.save
          user
        else
          User.create_from_twitter_hash_and_token(user_info, token) 
        end
      end

      def create_from_twitter_hash_and_token(user_info, access_token)
        user = User.new_from_twitter_hash(user_info)
        user.access_token = access_token.token
        user.access_secret = access_token.secret
        user.save
        user
      end
    end

    def token
      OAuth::AccessToken.new(TwitterAuth.consumer, access_token, access_secret)
    end 
  end
end
