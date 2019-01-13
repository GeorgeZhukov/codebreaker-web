require 'erb'
require 'codebreaker'
require 'pry'

# This is the main class for codebreaker game
class GameController
  PLAYERS_TEMPLATE = 'players.html.erb'.freeze
  TEMPLATES_BASE_FOLDER = 'templates/'.freeze
  INDEX_TEMPLATE = 'index.html.erb'.freeze

  def call(env)
    @request = Rack::Request.new(env)
    init_game
    dispatch
  end

  private

  def hint
    @game.hint
  end

  def new_game
    init_game(true)
    render_to_template(INDEX_TEMPLATE)
  end

  def guess
    @game.guess(guess_str)
  end

  def matches
    path.match(/[1-6]{4}/)
  end

  def guess_str
    matches[-1]
  end

  def cheat
    @game.cheat
  end

  def render(raw_data)
    Rack::Response.new(raw_data)
  end

  def render_to_template(template)
    ERB.new(template_file(template)).result(binding)
  end

  def template_file(template)
    File.read(template_path(template))
  end

  def template_path(template)
    File.expand_path("#{TEMPLATES_BASE_FOLDER}#{template}")
  end

  def save_score
    add_player_to_collection
    init_collection
    render_to_template(PLAYERS_TEMPLATE)
  end

  def init_collection
    @collection = Codebreaker::Player.load_collection
  end

  def add_player_to_collection
    Codebreaker::Player.add_to_collection(player)
  end

  def path
    @request.path
  end

  def username
    path.split('/')[-1]
  end

  def player
    Codebreaker::Player.new(username, availabe_attempts, @game.complete)
  end

  def availabe_attempts
    Codebreaker::Game::GIVEN_ATTEMPTS - @game.available_attempts
  end

  def not_found
    ['Not Found', 404]
  end

  def redirect_to_google
    [302, { 'Location' => 'http://google.com' }, []]
  end

  def dispatch
    result =
      case @request.path
      when '/hint'
        hint
      when %r(/^\/guess\/[1-6]{4}$/)
        guess
      when %r(/^\/save\/[a-zA-Z0-9]{3,8}$/)
        save_score
      when '/cheat'
        cheat
      when '/'
        new_game
      when '/trash'
        return Rack::Response.new.redirect(redirect_to_google)
      else
        not_found
      end
    render(result)
  end

  def init_game(force_new = false)
    # binding.pry
    @game = force_new && Codebreaker::Game.new
    @game ||= Codebreaker::Game.new
  end
end
