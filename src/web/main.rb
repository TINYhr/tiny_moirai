module TINYmoirai::Web
  class Main < TINYmoirai::Web::Base
    get '/' do
      user = begin
                TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
              rescue TINYmoirai::GithubAuthenticator::Unauthorized
                redirect '/login'
              end

      @email = user.email
      @fingerprint = if !user.public_key.nil?
                        SSHKey.fingerprint(user.public_key)
                      end

      slim :index
    end

    post '/export' do
      user = TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
      halt 403 unless user.valid?

      TINYmoirai::Export::Engage.new.execute do|exporter|
        exporter.execute(user.email, user.public_key)
      end

      redirect '/exported'
    end

    get '/exported' do
      user = TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
      halt 403 unless user.valid?

      slim :reported
    end

    get '/login' do
      redirect ::TINYmoirai::GithubAuthenticator.login_url
    end

    get '/logout' do
      ::TINYmoirai::GithubAuthenticator.logout do|auth_key|
        session[auth_key] = nil
      end
      redirect '/'
    end

    get '/callback' do
      success_handler = Proc.new do|auth_key, access_token|
                          session[auth_key] = access_token
                          redirect '/'
                        end
      TINYmoirai::GithubAuthenticator.authenticate(request.env['rack.request.query_hash']['code'],
                                                   success_handler,
                                                   -> { halt 403 })
    end
  end
end
