module ActiveMerchant
  module Billing
    module StripePaymentIntentsGatewayDecorator

      def extract_token_from_string_and_maybe_add_customer_id(post, payment_method)
        if payment_method.starts_with?('ctoken_')
          post[:confirmation_token] = payment_method
        end
        post[:automatic_payment_methods] = {
          enabled: true,
          allow_redirects: 'never'
        }
      end

    end
  end
end 


ActiveMerchant::Billing::StripePaymentIntentsGateway.prepend(ActiveMerchant::Billing::StripePaymentIntentsGatewayDecorator)
