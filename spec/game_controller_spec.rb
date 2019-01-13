require 'spec_helper'
require_relative '../game_controller'
require 'rack'

describe GameController do
  before do
    # Mock request
    request = double('request')
    allow(request).to receive(:path).and_return('/')
    allow(request).to receive(:session).and_return({})
    subject.instance_variable_set(:@request, request)

    # Mock render
    # allow(subject).to receive(:render) { |raw_data| raw_data }

    subject.send(:init_game)
  end

  let(:game) { subject.instance_variable_get(:@game) }

  describe '#hint' do
    it 'calls @game.hint' do
      expect(game).to receive(:hint).once
      subject.send(:hint)
    end

    it 'not renders hint' do
      expect(subject).not_to receive(:render)
      subject.send(:hint)
    end

    it 'returns hint string' do
      expect(subject.send(:hint)).to be_a(String)
    end
  end

  describe '#save_score' do
    before do
      allow(subject).to receive(:render_to_template).and_return('')
    end

    it 'calls #add_player_to_collection' do
      expect(subject).to receive(:add_player_to_collection).once
      subject.send(:save_score)
    end

    it 'calls #init_collection' do
      expect(subject).to receive(:init_collection).once
      subject.send(:save_score)
    end

    it 'calls #render_to_template with PLAYERS_TEMPLATE' do
      allow(subject).to receive(:render_to_template)
      expect(subject).to receive(:render_to_template).with(GameController::PLAYERS_TEMPLATE).once
      subject.send(:save_score)
    end
  end

  describe '#guess' do

    it 'returns a string' do
      allow(subject).to receive(:guess_str).and_return('1234')
      expect(subject.send(:guess)).to be_a(String)
    end
  end

  describe '#cheat' do
    it 'returns a string' do
      expect(subject.send(:cheat)).to be_a(String)
    end
  end

  describe '#render' do
    it 'returns a Rack::Response' do
      expect(subject.send(:render, '')).to be_a(Rack::Response)
    end
  end

  describe '#call' do
    before do
      # allow_any_instance_of(Rack::Request).to receive
      @request = double('Rack request')

      allow(Rack::Request).to receive(:new).and_return(@request)
      allow(@request).to receive(:session).and_return({})
    end

    it 'create Rack::Response 404 when path is wrong' do
      allow(@request).to receive(:path).and_return('/some-wrong-url')
      expect(Rack::Response).to receive(:new).with(['Not Found', 404]).once
      subject.call({})
    end
  end

  describe '#new_game' do
    it 'create a new game object' do
      old_game = game
      subject.send(:new_game)
      new_game = subject.instance_variable_get(:@game)
      expect(old_game).not_to equal new_game
    end

    it 'calls render_to_template with index.html.erb' do
      expect(subject).to receive(:render_to_template).with('index.html.erb').once
      subject.send(:new_game)
    end
  end

  describe '#save_score' do
    before do
      allow(Codebreaker::Player).to receive(:load_collection).and_return([])
      allow(Codebreaker::Player).to receive(:add_to_collection)
      request = subject.instance_variable_get(:@request)
      allow(request).to receive(:path).and_return('/save/George')
    end

    it 'gets username from request.path and pass it to Player.new' do
      expect(Codebreaker::Player).to receive(:new).with('George', 0, 0)
      subject.send(:save_score)
    end

    it 'calls Player.load_collection' do
      expect(Codebreaker::Player).to receive(:load_collection).once
      subject.send(:save_score)
    end

    it 'renders to players.html.erb template' do
      expect(subject).to receive(:render_to_template).with('players.html.erb').once
      subject.send(:save_score)
    end
  end

  describe '#guess' do
    before do
      request = subject.instance_variable_get(:@request)
      allow(request).to receive(:path).and_return('/guess/1234')
      allow(subject).to receive(:guess_str).and_return('1234')
    end

    it 'uses numbers from path to guess' do
      expect(game).to receive(:guess).with('1234').once
      subject.send(:guess)
    end

    it 'returns result of guess' do
      allow(game).to receive(:guess).and_return('++--')
      subject.send(:guess)
    end
  end

  describe '#cheat' do
    it 'calls game.cheat' do
      expect(game).to receive(:cheat).once
      subject.send(:cheat)
    end

    it 'returns cheat' do
      allow(game).to receive(:cheat).and_return('1234')
      subject.send(:cheat)
    end
  end

  describe '#render' do
    it 'create Rack::Response with given data' do
      game_controller = GameController.new
      expect(Rack::Response).to receive(:new).with('data')
      game_controller.send(:render, 'data')
    end
  end

  describe '#render_to_template' do
    it 'returns a String' do
      expect(subject.send(:render_to_template, 'index.html.erb')).to be_a(String)
    end
  end

  describe '#new_game' do
    it 'calls #init_game with true' do
      expect(subject).to receive(:init_game).with(true)
      subject.send(:new_game)
    end

    it 'returns a string' do
      expect(subject.send(:new_game)).to be_a(String)
    end
  end

  describe '#call' do
    let(:env) { Hash.new }

    it 'init @request' do
      subject.call(env)
      expect(subject.instance_variable_get(:@request)).to be_a(Rack::Request)
    end

    it 'calls #init_game' do
      expect(subject).to receive(:init_game).once
      subject.call(env)
    end

    it 'calls #dispatch' do
      expect(subject).to receive(:dispatch).once
      subject.call(env)
    end
  end

  describe '#dispatch' do
    before do
      allow(subject).to receive(:render).and_return('')
    end

    it 'returns a Rack::Response' do
      expect(subject.send(:dispatch)).to eq('')
    end

    it 'calls #hint' do
      allow(subject).to receive(:path).and_return('/hint')
      expect(subject).to receive(:hint).once
      subject.send(:dispatch)
    end

    it 'calls #guess' do
      allow(subject).to receive(:path).and_return('/guess/1234')
      expect(subject).to receive(:guess).once
      subject.send(:dispatch)
    end

    it 'calls #save_score' do
      allow(subject).to receive(:path).and_return('/save/George')
      expect(subject).to receive(:save_score).once
      subject.send(:dispatch)
    end

    it 'calls #cheat' do
      allow(subject).to receive(:path).and_return('/cheat')
      expect(subject).to receive(:cheat).once
      subject.send(:dispatch)
    end

    it 'calls #new_game' do
      allow(subject).to receive(:path).and_return('/')
      expect(subject).to receive(:new_game).once
      subject.send(:dispatch)
    end

    it 'calls #not_found' do
      allow(subject).to receive(:path).and_return('/hinewqeqweqwet')
      expect(subject).to receive(:not_found).once
      subject.send(:dispatch)
    end
  end

  describe '#guess_str' do
    it 'returns a String' do
      allow(subject).to receive(:matches).and_return(['', ''])
      expect(subject.send(:guess_str)).to be_a(String)
    end

  end

  describe '#matches' do
    it 'returns a String' do
      allow(subject).to receive(:path).and_return('/test/1234')
      expect(subject.send(:matches)).to be_a(MatchData)
    end
  end
end
