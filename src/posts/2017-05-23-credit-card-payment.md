<!--
{
  "title": "Credit Cart Payment Flow",
  "date": "2017-05-23T10:56:46+09:00",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# TODO

- architecture
  - identity
  - credentials
- specification


# Example

- stripe: https://stripe.com/docs/api
- solidus: https://github.com/solidusio/solidus
- solidus_gateway: https://github.com/solidusio/solidus_gateway/blob/master/app/models/spree/gateway/stripe_gateway.rb
- activemarchant: https://github.com/activemerchant/active_merchant

```
- CheckoutController#update with parameters
  {
    "order"=>{"payments_attributes"=>[{"payment_method_id"=>"2"}]},
    "payment_source"=>{"2"=>{"gateway_payment_profile_id"=>"tok_1AMRZIJPPMlh15WMoqXcVbrH", "name"=>"test-credit-card"}},
    "state"=>"payment"
  }
  =>
  - update_order =>
    - OrderUpdateAttributes.new and #apply
      (with update_params which move_payment_source_into_payments_attributes)
      => assign_payments_attributes =>
        - PaymentCreate.new and #build =>
          - order.payments.new and Payment#attributes= { payment_method_id: 2 }
          - build_source =>
            - Payment#source= CreditCard.new (Gateway#payment_source_class is CreditCard by default)
        - Order#save =>
          - Payment#save =>
            - (after_save :update_order)
            - (after_save :create_payment_profile)
            - Payment#create_payment_profile => Gateway::Stripe#create_profile =>
              - ActiveMerchant::Billing::StripeGateway#store =>
                - commit(:post, 'customers', ...)
              - update Payment#gateway_customer_profile_id, gateway_payment_profile_id with response
  - transition_forward => Order#next
  - send_to_next_state => redirect_to

- CheckoutController#update with { "state" => "confirm" }
  - transition_forward => Order#complete =>
    - (transition to: :complete, from: :confirm)
    - (before_transition to: :complete, do: :process_payments_before_complete)
      Order#process_payments_before_complete =>
      - Order::Payments#process_payments! =>
        - Payment#process! (as Payment::Processing#process!) =>
          - purchase! (if PaymentMethod#auto_capture?) => process_purchase =>
            - gateway_action =>
              - Gateway::Stripe#purchase (as PaymentMethod) =>
                - ActiveMerchant::Billing::StripeGateway#options_for_purchase_or_auth
                - ActiveMerchant::Billing::StripeGateway#purchase =>
                  - commit(:post, 'charges', ...)
              - handle_response => Payment#response_code= response.authorization
    - (after_transition to: :complete, do: :finalize!)
      Order#finalize! => OrderUpdater#update_payment_state

- Order#canceled_by => #cancel! =>
  - (event :cancel transition to: :canceled, if: :allow_cancel?)
  - (after_transition to: :canceled, do: :after_cancel)
    Order#after_cancel =>
    - Payment#cancel! (as Payment::Processing) =>
      - Gateway::Stripe#cancel => ActiveMerchant::Billing::StripeGateway#void =>
        - commit(:post, "charges/#{CGI.escape(identification)}/refunds, ...)

- Payment#refund ??
  - Gateway::StripeGateway#credit =>
    - ActiveMerchant::Billing::StripeGateway#refund =>
      - commit(:post, "charges/#{CGI.escape(identification)}/refunds", ...)
```
