require 'erb'
require 'codebreaker'

use Rack::Static, :urls => ["/assets"]
use Rack::Session::Cookie, :key => 'rack.session',
                           :secret => 'something secret should be here'

class Racker
  def call(env)
    @request = Rack::Request.new(env)
    @game = @request.session[:game] ||= Codebreaker::Game.new

    case @request.path  
    when "/hint"
      hint  
    when /^\/guess\/[1-6]{4}$/
      guess
    when /^\/save\/[a-zA-Z0-9]{3,8}$/
      save_score
    when "/cheat"
      cheat
    when "/"
      new_game
    else
      # 404
      Rack::Response.new("Not Found", 404)
    end    
  end

  def hint
    hint = @game.hint
    Rack::Response.new(hint)
  end

  def new_game
    # Default page, new game
    @game = @request.session[:game] = Codebreaker::Game.new
    Rack::Response.new(render("index.html.erb"))
  end

  def save_score
    username = @request.path.split("/")[-1]
    player = Codebreaker::Player.new(username, 10 - @game.available_attempts, @game.complete)
    Codebreaker::Player.add_to_collection player
    @collection = Codebreaker::Player.load_collection
    Rack::Response.new(render("players.html.erb"))
  end

  def guess
    matches = @request.path.match /[1-6]{4}/
    guess = matches[-1]
    result = @game.guess guess
    Rack::Response.new(result)
  end

  def cheat
    result = @game.cheat
    Rack::Response.new(result)
  end
  
  def render(template)
    path = File.expand_path("templates/#{template}")
    ERB.new(File.read(path)).result(binding)
  end
end
 
run Racker.new