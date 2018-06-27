class HerokuDeregisteredListener
  include Sneakers::Worker
  from_queue :"tpops.heroku_proxy.deleted_user"


  def work(msg)
    data = JSON.parse(msg)
    email = data["email"]

    local_user = ::User.find_by(email: email)
    ::HerokuAccess.where(user_id: local_user.id).active.each do|access|
      access.update(active: false)
    end

    ack!
  end
end
