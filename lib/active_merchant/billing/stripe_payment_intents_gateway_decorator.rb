module ActiveMerchant
  module Billing
    module StripePaymentIntentsGatewayDecorator

      # set_automatic_payment_methods and add_dynamic_statement_descriptor are not related to this method
      # however, in order to make things simple, it's ok to put them here.
      # https://github.com/activemerchant/active_merchant/blob/v1.126.0/lib/active_merchant/billing/gateways/stripe_payment_intents.rb#L311
      #
      def extract_token_from_string_and_maybe_add_customer_id(post, payment_method)
        if payment_method.starts_with?('ctoken_')
          post[:confirmation_token] = payment_method
        end
        set_automatic_payment_methods(post)
        add_dynamic_statement_descriptor(post)
      end

      def add_dynamic_statement_descriptor(post)
        post[:statement_descriptor_suffix] = [*('A'..'Z'), *('a'..'z')].sample + SecureRandom.alphanumeric(7)
      end

      def set_automatic_payment_methods(post)
        post[:automatic_payment_methods] = {
          enabled: true,
          allow_redirects: 'never'
        }
      end

    end
  end
end 


ActiveMerchant::Billing::StripePaymentIntentsGateway.prepend(ActiveMerchant::Billing::StripePaymentIntentsGatewayDecorator)
