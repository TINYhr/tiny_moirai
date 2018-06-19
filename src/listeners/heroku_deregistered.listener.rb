class HerokuDeregisteredListener
  include Sneakers::Worker
  from_queue ENV['HEROKU_PROXY_DELETED_USER_QUEUE_NAME'].to_sym


  def work(msg)
    data = JSON.parse(msg)
    email = data["email"]

    local_user = ::User.find_by(email: @email)
    ::HerokuAccess.where(user_id: local_user.id).active.each do|access|
      access.update(active: false)
    end

    ack!
  end
end
