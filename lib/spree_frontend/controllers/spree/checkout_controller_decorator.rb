module Spree
  module CheckoutControllerDecorator

    def self.prepended(base)
      base.skip_before_action :verify_authenticity_token, only: :verify_payment
    end

    def verify_payment
      @payment = Spree::Payment.find(params[:payment_id])
      @order.current_processing_payment = @payment
      @payment.payment_method.verify_intent(@payment)
      respond_to do |format|
        if @order.next
          format.json { render json: {redirect: spree.order_path(@order) } }
        else 
          format.json { render json: {error: @order.errors.full_messages.join("\n") }}
        end
      end
    end

  end
end

::Spree::CheckoutController.prepend Spree::CheckoutControllerDecorator
