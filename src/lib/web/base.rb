module TINYmoirai
  module Web
    class Base < ::Sinatra::Base
      set :views, File.expand_path(File.join(__FILE__, '../../../views'))
      before do
        content_type :html
      end

      configure :development do
        register Sinatra::Reloader
      end

      error do
        "Unknown error"
      end
    end
  end
end
