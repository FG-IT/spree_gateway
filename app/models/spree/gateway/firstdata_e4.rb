module Spree
  class Gateway::FirstdataE4 < Gateway
    preference :login, :string
    preference :password, :string
    preference :key_id, :string
    preference :hmac_key, :string
    preference :server, :string, default: "test"

    def provider
      gateway_options = options
      gateway_options[:test_requests] = false
      ActiveMerchant::Billing::FirstdataE4V27Gateway.test_url = 'https://api.demo.globalgatewaye4.firstdata.com/transaction/v32'
      ActiveMerchant::Billing::FirstdataE4V27Gateway.live_url = 'https://api.globalgatewaye4.firstdata.com/transaction/v32'

      @provider ||= provider_class.new(gateway_options)
    end

    def provider_class
      ActiveMerchant::Billing::FirstdataE4V27Gateway
    end

    def options
      if !['live', 'test'].include?(self.preferred_server)
        raise "You must set the 'server' preference in your payment method (Gateway::AuthorizeNet) to either 'live' or 'test'"
      end
      super().merge(
        test: (self.preferred_server != "live"),
        key_id: self.preferred_key_id,
        hmac_key: self.preferred_hmac_key
      )
    end




    def cancel(response_code)
      provider
      # From: http://community.developer.authorize.net/t5/The-Authorize-Net-Developer-Blog/Refunds-in-Retail-A-user-friendly-approach-using-AIM/ba-p/9848
      # DD: if unsettled, void needed
      response = provider.void(response_code)
      # DD: if settled, credit/refund needed (CAN'T DO WITHOUT CREDIT CARD ON AUTH.NET)
      # response = provider.refund(response_code) unless response.success?

      response
    end

    def credit(amount, response_code, refund, gateway_options = {})
      gateway_options[:card_number] = refund[:originator].payment.source.last_digits
      auth_net_gateway.refund(amount, response_code, gateway_options)
    end

    private

    def auth_net_gateway
      @_auth_net_gateway ||= begin
                               ActiveMerchant::Billing::Base.gateway_mode = preferred_server.to_sym
                               gateway_options = options
                               gateway_options[:test_requests] = false # DD: never ever do test requests because just returns transaction_id = 0
                               ActiveMerchant::Billing::FirstdataE4V27Gateway.test_url = 'https://api.demo.globalgatewaye4.firstdata.com/transaction/v32'
                               ActiveMerchant::Billing::FirstdataE4V27Gateway.live_url = 'https://api.globalgatewaye4.firstdata.com/transaction/v32'
                               ActiveMerchant::Billing::FirstdataE4V27Gateway.new(gateway_options)
                             end
    end
  end
end
