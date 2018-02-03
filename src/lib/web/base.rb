module TINYmoirai
  module Web
    class Base < ::Sinatra::Base
      configure :development do
        register Sinatra::Reloader
      end

      error do
        content_type :json
        {message: "Unknown error"}.to_json
      end
    end
  end
end
