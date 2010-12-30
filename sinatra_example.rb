
require 'sinatra'  ##

## from https://github.com/josh/rack-openid except where marked with ##

# Session needs to be before Rack::OpenID
use Rack::Session::Cookie

require 'rack/openid'
##use Rack::OpenID
##
require 'openid/store/memcache'
require 'dalli'
use Rack::OpenID,
  OpenID::Store::Memcache.new(Dalli::Client.new)

OpenID.fetcher.ca_file = "curl-ca-bundle.crt"

# FIXME See https://github.com/openid/ruby-openid/pull/9
module OpenID
  module Store
    class Memcache
      def use_nonce(server_url, timestamp, salt)
        return false if (timestamp - Time.now.to_i).abs > Nonce.skew
        ts = timestamp.to_s # base 10 seconds since epoch
        nonce_key = key_prefix + 'N' + server_url + '|' + ts + '|' + salt
        result = @cache_client.add(nonce_key, '', expiry(Nonce.skew + 5))
        
        if result.is_a? String
          return !!(result =~ /^STORED/)
        else
          return result == true
        end
      end
      
      def delete(key)
        result = @cache_client.delete(key)
        
        if result.is_a? String
          return !!(result =~ /^DELETED/)
        else
          return result == true
        end
      end
    end
  end
end

get '/' do
  redirect '/login'
end
##

get '/login' do
  erb :login
end

post '/login' do
  if resp = request.env["rack.openid.response"]
    if resp.status == :success
      @message = "Welcome: #{resp.display_identifier}"  ##
    else
      @message = "Error: #{resp.inspect}"  ##
    end
    erb :login
  else
    headers 'WWW-Authenticate' =>
      Rack::OpenID.build_header(:identifier => params["openid_identifier"])
    throw :halt, [401, 'got openid?']
  end
end


##use_in_file_templates!
include ERB::Util  ##

__END__

@@ login
  <form action="/login" method="post">
    <p>
      <label for="openid_identifier">OpenID:</label>
      <input id="openid_identifier" name="openid_identifier" type="text" />
    </p>

    <p>
      <input name="commit" type="submit" value="Sign in" />
    </p>
  </form>

@@##

@@ layout
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">	
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>rack-openid test</title></head>
<body>
    <h1><a href="https://github.com/josh/rack-openid"
          title="the source">rack-openid</a> test
      (<a href="https://github.com/josh/rack-openid"
         title="the source">sinatra example</a> based)</h1>
    <div id="content">
        <div id="message">
          <strong><%= h(@message ||'Please enter your URL below') %></strong>
          </div>
        <%= yield %></div>
</body></html>
