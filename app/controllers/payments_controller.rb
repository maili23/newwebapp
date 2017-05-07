class PaymentsController < ApplicationController

  # Set your secret key: remember to change this to your live secret key in production
# See your keys here: https://dashboard.stripe.com/account/apikeys
  Stripe.api_key = "sk_test_1EE1kLy0CZfu2RJhI4hl5fJu"

  def create
    token = params[:stripeToken]
    @product = Product.find(params[:product_id])
    @user = current_user
  # Create the charge on Stripe's servers - this will charge the user's card
    begin
      charge = Stripe::Charge.create(
        :amount => (@product.price*100).to_i, # amount in cents, again
        :currency => "usd",
        :source => token,
        :description => @product.description,
        :receipt_email => @user.email
        )

        if charge.paid
          Order.create!(product_id: @product.id, user_id: @user.id, total: @product.price)
        end

        flash[:success] = "Your order will be shiped soon"
      rescue Stripe::CardError => e
        # The card has been declined
        body = e.json_body
        err = body[:error]
        flash[:error] = "Unfortunately, there was an error processing your payment: #{err[:message]}"
      end

      redirect_to product_path(@product)
  end
end