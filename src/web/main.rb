module TINYmoirai::Web
  class Main < TINYmoirai::Web::Base
    get '/' do
      @welcome = "Hello world"
      slim :index
    end

    get '/secured' do
      @welcome = "I'm very secured."
      slim :secured
    end
  end
end
