require './game_controller'

use Rack::Static, urls: ['/assets']
use Rack::Session::Cookie, key: 'rack.session',
                           secret: 'something secret should be here'

run GameController.new
