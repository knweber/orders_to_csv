class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :shopify_order_id
      t.string :unique_order_number
      t.string :email
      t.string :phone
      t.string :first_name
      t.string :last_name
      t.decimal :total_price
      t.decimal :subtotal
      t.decimal :total_discounts
      t.jsonb :tags
      t.jsonb :line_items

      t.string :billing_customer_name
      t.string :billing_address
      t.string :billing_city
      t.string :billing_zip
      t.string :billing_state
      t.string :billing_country

      t.string :shipping_address
      t.string :shipping_address2
      t.string :shipping_city
      t.string :shipping_zip
      t.string :shipping_state
      t.string :shipping_country
    end
  end
end
