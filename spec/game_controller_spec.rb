require 'spec_helper'
require_relative '../game_controller'
require 'rack'

describe GameController do
	before do
		# Mock request
		request = double("request")
		allow(request).to receive(:path).and_return("/")
		allow(request).to receive(:session).and_return({})
		subject.instance_variable_set(:@request, request)

		# Mock render
		allow(subject).to receive(:render) { |raw_data| raw_data }
		
		subject.send(:init_game)
	end

	let(:game) { subject.instance_variable_get(:@game) }

	describe "#hint" do
		it "calls @game.hint" do
			expect(game).to receive(:hint).once
			subject.hint
		end

		it "renders hint" do
			expect(subject).to receive(:render).once
			subject.hint
		end
	end
  
  describe "#call" do
        
    before do
      # allow_any_instance_of(Rack::Request).to receive
      @request = double("Rack request")

      allow(Rack::Request).to receive(:new).and_return(@request)
      allow(@request).to receive(:session).and_return({})
    end
    
    routes = {
      '/hint' => :hint,
      '/guess/1234' => :guess,
      '/save/George' => :save_score,
      '/cheat' => :cheat,
      '/' => :new_game,
    }
    
    routes.each do |url,method|
      it "calls ##{method} when path is '#{url}'" do
        allow(@request).to receive(:path).and_return(url)
        expect(subject).to receive(method).once
        subject.call({})
      end
    end
    
    it "create Rack::Response 404 when path is wrong" do
      allow(@request).to receive(:path).and_return('/some-wrong-url')
      expect(Rack::Response).to receive(:new).with("Not Found", 404).once
      subject.call({})
    end
      
  end

	describe "#new_game" do
		it "create a new game object" do
			old_game = game
			subject.new_game
			new_game = subject.instance_variable_get(:@game)
			expect(old_game).not_to equal new_game
		end

		it "calls render_to_template with index.html.erb" do
			expect(subject).to receive(:render_to_template).with("index.html.erb").once
			subject.new_game
		end
	end

	describe "#save_score" do
		before do
			allow(Codebreaker::Player).to receive(:load_collection).and_return([])
			allow(Codebreaker::Player).to receive(:add_to_collection)
			request = subject.instance_variable_get(:@request)
			allow(request).to receive(:path).and_return("/save/George")
		end

		it "gets username from request.path and pass it to Player.new" do
			expect(Codebreaker::Player).to receive(:new).with("George", 0, 0)
			subject.save_score
		end

		it "calls Player.load_collection" do
			expect(Codebreaker::Player).to receive(:load_collection).once
			subject.save_score
		end

		it "renders to players.html.erb template" do
			expect(subject).to receive(:render_to_template).with("players.html.erb").once
			subject.save_score
		end
	end

	describe "#guess" do
		before do
			request = subject.instance_variable_get(:@request)
			allow(request).to receive(:path).and_return("/guess/1234")
		end

		it "uses numbers from path to guess" do
			expect(game).to receive(:guess).with("1234").once
			subject.guess			
		end

		it "renders result of guess" do
			allow(game).to receive(:guess).and_return("++--")
			expect(subject).to receive(:render).with("++--")
			subject.guess
		end
	end

	describe "#cheat" do
		it "calls game.cheat" do
			expect(game).to receive(:cheat).once
			subject.cheat
		end

		it "renders cheat" do
			allow(game).to receive(:cheat).and_return("1234")
			expect(subject).to receive(:render).with("1234").once
			subject.cheat

		end
	end
  
  describe "#render" do
    it "create Rack::Response with given data" do
      game_controller = GameController.new
      expect(Rack::Response).to receive(:new).with("data")
      game_controller.render("data")
    end
  end

	describe "#render_to_template" do
		it "calls render" do
			expect(subject).to receive(:render).once
			subject.render_to_template("index.html.erb")
		end
	end
end