# NOTE: just a helper to fake sending a created_user message back to the app
# Usage:
# TINYmoirai::Heroku::CreatedUser.execute do |e|
#   e.execute('user@example.com')
# end
module TINYmoirai
  module Heroku
    class CreatedUser
      def initialize
        @bunny_connection = Bunny.new(ENV['AMQP_ENDPOINT'])
      end

      def execute(email = nil)
        if block_given?
          @bunny_connection.start
          yield(self)
          dispose
        elsif email
          publish(email: email)
        else
          raise ::StandardError.new("Please provide email or execution block!!!")
        end
      end

      private

      def serialize(data)
        data.to_json
      end

      def publish(data)
        publisher.publish(serialize(data), routing_key: queue.name)
      end

      def publisher
        @publisher ||= channel.default_exchange
      end

      def queue
        @queue ||= channel.queue('tpops.heroku_proxy.created_user', durable: true)
      end

      def channel
        @channel ||= @bunny_connection.create_channel
      end

      def dispose
        @bunny_connection.stop
        @channel = nil
        @queue = nil
        @publisher = nil
      end
    end
  end
end
