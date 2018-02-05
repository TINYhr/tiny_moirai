module TINYmoirai
  module Export
    class Engage
      def initialize
        @bunny_connection = Bunny.new(bunny_opts)
      end

      def execute(email = nil, public_key = nil)
        if block_given?
          @bunny_connection.start
          yield(self)
          dispose
        elsif email.present? && public_key.present?
          publish({email: email, public_key: public_key})
        end

        raise StanndardError.new("Please provide email with public_key or execution block!!!")
      end

      private

      def serialize(data)
        data.to_s
      end

      def publish(data)
        publisher.publish(serialize(data), :routing_key => queue.name)
      end

      def publisher
        @publisher ||= channel.default_exchange
      end

      def queue
        @queue ||= channel.queue("tpops.export.engage", :durable => true)
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
