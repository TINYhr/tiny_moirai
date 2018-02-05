module TINYmoirai::Web
  class Main < TINYmoirai::Web::Base
    get '/' do
      if session[:gh_atk].nil?
        redirect '/login'
        return
      end

      access_token = session[:gh_atk]
      scopes = []

      client = Octokit::Client.new(client_id: CLIENT_ID, client_secret: CLIENT_SECRET)
      begin
        client.check_application_authorization(access_token)
      rescue => e
        session[:access_token] = nil

        redirect '/login'
        return
      end

      client = Octokit::Client.new(:access_token => session[:gh_atk])
      user = client.user

      if !client.organization_member?("TINYhr", user.login)
        halt 403
      end

      @email = client.emails.detect{|email| email[:primary] }[:email]
      @public_key = client.keys.detect {|public_key| public_key[:verified] }[:key]

      # TODO: [AV] Raise error if @email or @public_key is not ready

      slim :index
    end

    post '/export' do
      client = Octokit::Client.new(:access_token => session[:gh_atk])
      user = client.user

      if !client.organization_member?("TINYhr", user.login)
        halt 403
      end

      @email = client.emails.detect{|email| email[:primary] }[:email]
      @public_key = client.keys.detect {|public_key| public_key[:verified] }[:key]

      TINYmoirai::Export::Engage.new.execute do|exporter|
        exporter.execute(@email, @public_key)
      end

      redirect '/'
    end

    get '/login' do
      client = Octokit::Client.new
      url = client.authorize_url(CLIENT_ID, :scope => 'user:email,read:public_key,read:org,read:gpg_key')

      redirect url
    end

    get '/callback' do
      if request.env['rack.request.query_hash']['code'].nil?
        redirect '/login'
        return
      end

      session_code = request.env['rack.request.query_hash']['code']
      result = Octokit.exchange_code_for_token(session_code, CLIENT_ID, CLIENT_SECRET)
      access_token = result[:access_token]

      session[:gh_atk] = access_token

      client = Octokit::Client.new(:access_token => session[:gh_atk])
      begin
        current_user = client.user
      rescue Octokit::Unauthorized
        redirect '/login'
        return
      end

      if !client.organization_member?("TINYhr", client.user.login)
        halt 403
      end

      redirect '/'
    end
  end
end
