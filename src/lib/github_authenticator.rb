module TINYmoirai
  class GithubAuthenticator
    ORGANIZATION_NAME = "TINYhr".freeze
    ORGANIZATION_EMAIL_PATTERN = /@tinypulse.com\z/

    def self.login_url
      Octokit::Client.new.authorize_url(Octokit.client_id, :scope => 'user:email,read:public_key,read:org,read:gpg_key')
    end

    def self.logout(session)
      session.delete(:gh_atk)
    end

    def self.authenticate(session, session_code, success_handler, failure_handler)
      if session_code.nil?
        failure_handler.call
        return
      end

      result = Octokit.exchange_code_for_token(session_code, Octokit.client_id, Octokit.client_secret)
      access_token = result[:access_token]
      session[:gh_atk] = access_token

      client = Octokit::Client.new(:access_token => access_token)
      begin
        client.user
      rescue Octokit::Unauthorized
        failure_handler.call
        return
      end

      if !client.organization_member?(ORGANIZATION_NAME, client.user.login)
        failure_handler.call
        return
      end

      success_handler.call
    end

    def initialize(session)
      raise TINYmoirai::GithubAuthenticator::Unauthorized if session[:gh_atk].nil?
      access_token = session[:gh_atk]

      @client = Octokit::Client.new(:access_token => access_token)
      @client.check_application_authorization(access_token)
      @user = @client.user
      if !@client.organization_member?(ORGANIZATION_NAME, @user.login)
        raise TINYmoirai::GithubAuthenticator::Unauthorized
      end
    end

    def email
      primary_email = @client.emails.detect{|email| email[:primary] }
      if !primary_email.nil?
        primary_email[:email]
      else
        nil
      end
    end

    def public_key
      first_verified_public_key = @client.keys.detect {|public_key| public_key[:verified] }
      @public_key = if first_verified_public_key.nil?
                      nil
                    else
                      first_verified_public_key[:key]
                    end
    end

    def valid?
      !email.nil? && !public_key.nil?
    end

    def authorize(session)
    end

    private
    def email_matched?
      !!ORGANIZATION_EMAIL_PATTERN.match(email)
    end

    class Unauthorized < ::StandardError
    end
  end
end
