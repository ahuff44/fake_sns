module FakeSNS
  module Actions
    class Publish < Action

      param message: "Message"
      param message_structure: "MessageStructure" do nil end
      param subject: "Subject" do nil end
      param target_arn: "TargetArn" do nil end
      param topic_arn: "TopicArn" do nil end

      def call
        if (bytes = message.bytesize) > 262144
          raise InvalidParameterValue, "Too much bytes: #{bytes} > 262144."
        end
        @topic = db.topics.fetch(topic_arn) do
          raise InvalidParameterValue, "Unknown topic: #{topic_arn}" unless target_arn
        end
        if target_arn =~ /arn:aws:sns:[a-z0-9\\-]+:[0-9]+:endpoint\/(GCM|APNS|APNS_SANDBOX)\/DebugApp\/endpointdisabled/
          raise InvalidParameterValue, "EndpointDisabled: Endpoint is disabled"
        end

        @message_id = SecureRandom.uuid

        db.messages.create(
          id:          message_id,
          subject:     subject,
          message:     message,
          topic_arn:   topic_arn,
          structure:   message_structure,
          target_arn:  target_arn,
          received_at: Time.now,
        )
      end

      def message_id
        @message_id || raise(InternalFailure, "no message id yet, this should not happen")
      end

    end
  end
end
