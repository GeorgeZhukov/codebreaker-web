require 'erb'
require 'codebreaker'

class GameController
  def call(env)
    @request = Rack::Request.new(env)
    init_game

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
    render(hint)
  end

  def new_game
    # Default page, new game
    init_game(true)
    render_to_template("index.html.erb")
  end

  def save_score
    username = @request.path.split("/")[-1]
    player = Codebreaker::Player.new(username, 10 - @game.available_attempts, @game.complete)
    Codebreaker::Player.add_to_collection player
    @collection = Codebreaker::Player.load_collection
    render_to_template("players.html.erb")
  end

  def guess
    matches = @request.path.match /[1-6]{4}/
    guess = matches[-1]
    result = @game.guess guess
    render(result)
  end

  def cheat
    result = @game.cheat
    render(result)
  end
  
  def render(raw_data)
    Rack::Response.new(raw_data)
  end

  def render_to_template(template)
    path = File.expand_path("templates/#{template}")
    result = ERB.new(File.read(path)).result(binding)
    render(result)
  end

  private
  def init_game(force_new=false)
    @game = if force_new
      @request.session[:game] = Codebreaker::Game.new
    else
      @request.session[:game] ||= Codebreaker::Game.new
    end    
  end
end