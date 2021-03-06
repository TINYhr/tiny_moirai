class HerokuRegisteredListener
  include Sneakers::Worker
  from_queue :"tpops.heroku_proxy.created_user"


  def work(msg)
    data = JSON.parse(msg)
    email = data["email"]

    local_user = ::User.find_by(email: email)
    ::HerokuAccess.where(user_id: local_user.id).ready.each do|access|
      access.update(active: true)
    end

    ack!
  end
end
