require 'erb'
require 'codebreaker'

use Rack::Static, :urls => ["/assets"]
use Rack::Session::Cookie, :key => 'rack.session',
                           :secret => 'something secret should be here'

class Racker
  def call(env)
    request = Rack::Request.new(env)
    
    request.session[:game] ||= Codebreaker::Game.new
    
    if request.path == "/new"
      request.session[:game] = Codebreaker::Game.new
      Rack::Response.new(render("index.html.erb"))
    else
      Rack::Response.new(request.session[:game].hint)
    end
    
  end
  
  def render(template)
    path = File.expand_path("templates/#{template}")
    ERB.new(File.read(path)).result(binding)
  end
end
 
run Racker.new