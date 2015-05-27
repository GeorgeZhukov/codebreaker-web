require 'erb'
require 'codebreaker'

use Rack::Static, :urls => ["/assets"]
use Rack::Session::Cookie, :key => 'rack.session',
                           :secret => 'something secret should be here'

class Racker
  def call(env)
    request = Rack::Request.new(env)
    request.session[:game] ||= Codebreaker::Game.new

    case request.path  
    when "/hint"
      hint = request.session[:game].hint
      Rack::Response.new(hint)
    when /^\/guess\/[1-6]{4}$/
      matches = request.path.match /[1-6]{4}/
      guess = matches[-1]
      result = request.session[:game].guess guess
      Rack::Response.new(result)
    when /^\/save\/[a-zA-Z0-9]{3,8}$/
      username = request.path.split("/")[-1]
      player = Codebreaker::Player.new(username, 10 - request.session[:game].available_attempts, request.session[:game].complete)
      Codebreaker::Player.add_to_collection player
      @collection = Codebreaker::Player.load_collection
      Rack::Response.new(render("players.html.erb"))
    when "/cheat"
      result = request.session[:game].cheat
      Rack::Response.new(result)
    when "/"
      puts request.inspect
      # Default page, new game
      request.session[:game] = Codebreaker::Game.new
      Rack::Response.new(render("index.html.erb"))
    else
      # 404
      Rack::Response.new("Not Found", 404)
    end
    
  end
  
  def render(template)
    path = File.expand_path("templates/#{template}")
    ERB.new(File.read(path)).result(binding)
  end
end
 
run Racker.new