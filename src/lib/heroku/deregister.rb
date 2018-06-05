module TINYmoirai
  module Heroku
    class Deregister
      def initialize
        @bunny_connection = Bunny.new(ENV['AMQP_ENDPOINT'])
      end

      def execute(email)
        if block_given?
          @bunny_connection.start
          yield(self)
          dispose
        elsif !email.nil?
          publish({email: email})
        else
          raise ::StandardError.new("Please provide email with public_key or execution block!!!")
        end
      end

      private

      def serialize(data)
        data.to_json
      end

      def publish(data)
        publisher.publish(serialize(data), :routing_key => queue.name)
      end

      def publisher
        @publisher ||= channel.default_exchange
      end

      def queue
        @queue ||= channel.queue("tpops.heroku.deregister", :durable => true)
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
