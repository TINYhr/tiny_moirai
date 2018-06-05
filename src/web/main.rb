module TINYmoirai::Web
  class Main < TINYmoirai::Web::Base
    get '/' do
      @user = begin
                TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
              rescue TINYmoirai::GithubAuthenticator::Unauthorized
              end

      slim :index
    end

    get '/export' do
      @user = begin
                TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
              rescue TINYmoirai::GithubAuthenticator::Unauthorized
                redirect '/login'
              end

      @email = @user.email
      @fingerprint = if !@user.public_key.nil?
                        SSHKey.fingerprint(@user.public_key)
                      end
      slim :export
    end

    post '/export' do
      @user = TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
      halt 403 unless @user.valid?

      TINYmoirai::Export::Engage.new.execute do|exporter|
        exporter.execute(@user.email, @user.public_key)
      end

      redirect '/exported'
    end

    get '/exported' do
      @user = TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
      halt 403 unless @user.valid?

      slim :reported
    end

    get '/heroku' do
      @user = TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
      halt 403 unless @user.valid?

      @email = @user.email

      local_user = ::User.find_by(email: @email)
      @fingerprint = local_user.fingerprint
      @access = ::HerokuAccess.where(user_id: local_user.id).active.first

      @login = @email.split('@').first

      slim :heroku
    end

    post '/heroku' do
      @user = TINYmoirai::GithubAuthenticator.new(session[TINYmoirai::GithubAuthenticator::AUTH_KEY])
      halt 403 unless @user.valid?

      local_user = ::User.find_by(email: @user.email)

      access = ::HerokuAccess.where(user_id: local_user.id).active.first
      if access.nil?
        ::HerokuAccess.create(user_id: local_user.id, created_at: Time.now)
        TINYmoirai::Heroku::Register.new.execute do|exporter|
          exporter.execute(@user.email, @user.public_key)
        end
      end

      redirect '/heroku'
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

                          github_user = TINYmoirai::GithubAuthenticator.new(access_token)
                          user        = User.where(email: github_user.email).first || User.new(email: github_user.email)
                          user.public_key    = github_user.public_key
                          user.github_login  = github_user.login
                          user.fingerprint   = SSHKey.fingerprint(github_user.public_key)
                          user.save

                          redirect '/'
                        end
      TINYmoirai::GithubAuthenticator.authenticate(request.env['rack.request.query_hash']['code'],
                                                   success_handler,
                                                   -> { halt 403 })
    end
  end
end
