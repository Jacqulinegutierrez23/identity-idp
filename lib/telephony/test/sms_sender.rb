module Telephony
  module Test
    class SmsSender
      def send(message:, to:, country_code:, otp: nil)
        error = ErrorSimulator.new.error_for_number(to)
        if error.nil?
          Message.messages.push(Message.new(body: message, to: to, otp: otp))
          success_response
        else
          Response.new(
            success: false, error: error, extra: { request_id: 'fake-message-request-id' },
          )
        end
      end

      def phone_info(phone_number)
        error = ErrorSimulator.new.error_for_number(phone_number)
        case error
        when InvalidCallingAreaError
          PhoneNumberInfo.new(
            type: :voip,
            carrier: 'Test VOIP Carrier',
          )
        # Mask opt out errors because we do a phone_info check before trying to send
        # so it would prevent us from getting an opt out error where it would actually appaer
        when OptOutError
          PhoneNumberInfo.new(
            type: :mobile,
            carrier: 'Test Mobile Carrier',
          )
        when TelephonyError
          PhoneNumberInfo.new(
            type: :unknown,
            error: error,
          )
        else
          PhoneNumberInfo.new(
            type: :mobile,
            carrier: 'Test Mobile Carrier',
          )
        end
      end

      def success_response
        Response.new(
          success: true,
          extra: { request_id: 'fake-message-request-id', message_id: 'fake-message-id' },
        )
      end
    end
  end
end
