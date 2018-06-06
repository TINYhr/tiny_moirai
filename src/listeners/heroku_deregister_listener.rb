class HerokuDeregisterListener
  include Sneakers::Worker
  from_queue :"tpops.heroku.deregister"


  def work(msg)
    data = Marshal.load(msg)

    # TODO: [AV] Cleanup db

    ack!
  end
end
