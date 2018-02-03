module TINYmoirai::Web
  class Main < TINYmoirai::Web::Base
    get '/' do
      "Hello world"
    end

    get '/secured' do
      "I'm very secured."
    end
  end
end
