module TINYmoirai
  module Web
    class Base < ::Sinatra::Base
      set :views, File.expand_path(File.join(__FILE__, '../../../views'))
      set :public_folder, File.expand_path(File.join(__FILE__, '../../../public'))

      before do
        content_type :html
      end
      # enable :sessions
      use Rack::Session::Cookie, :key => "rack.session",
                                 :path => "/",
                                 :secret => ENV['SECRET_TOKEN']

      configure :development do
        register Sinatra::Reloader
      end

      error do
        "Unknown error"
      end
    end
  end
end
