require 'shopify_api'
require 'json'
require 'csv'
require 'date'
# require 'dotenv'

# module Influencer
#   class OrderCreator
#
#     def initialize
      # Dotenv.load
      $apikey = ENV['ELLIE_STAGING_API_KEY']
      $password = ENV['ELLIE_STAGING_PASSWORD']
      $shopname = ENV['SHOPNAME']
      ShopifyAPI::Base.site = "https://#{$apikey}:#{$password}@#{$shopname}.myshopify.com/admin"
    # end

    # get all unfulfilled orders
    def pull_orders
      # adjust created_at date
      ShopifyAPI::Order.find(:all, :params => {:created_at_min => '2017-12-01', :fulfillment_status => nil})
    end

    def create_orders
      my_shopify_orders = pull_orders
      puts "** Number of orders to fulfill: #{my_shopify_orders.length} **"
      puts "*************"

      orders_for_csv = []

      my_shopify_orders.each do |order|
        puts "NEW ORDER"
        order = order.as_json
        unique_order_number = "#IN" + SecureRandom.random_number(36**12).to_s(36).rjust(12,"0")

        default_address = order["default_address"].as_json

        billing_address = order["billing_address"].as_json

        shipping_address = order["shipping_address"].as_json

        new_order = {
          shopify_order_id: order["id"],
          unique_order_number: unique_order_number,
          email: order["email"],
          phone: order["phone"],
          first_name: shipping_address["first_name"],
          last_name: shipping_address["last_name"],
          total_price: order["total_price"],
          subtotal: order["subtotal_price"],
          total_discounts: order["total_discounts"],
          # tags: order["tags"],
          # line_items: order["line_items"],
          billing_customer_name: billing_address["name"],
          billing_address: billing_address["address1"],
          billing_city: billing_address["city"],
          billing_zip: billing_address["zip"],
          billing_state: billing_address["province"],
          billing_country: billing_address["country"],
          shipping_address: shipping_address["address1"],
          shipping_address2: shipping_address["address2"],
          shipping_city: shipping_address["city"],
          shipping_zip: shipping_address["zip"],
          shipping_state: shipping_address["province"],
          shipping_country: shipping_address["country"]
        }

        puts "_____"
        puts "Order"
        puts JSON.pretty_generate(new_order)
        puts "_____"
        puts "Line Items in Order:"
        puts JSON.pretty_generate(order["line_items"].as_json)
        puts "_____"
        puts "Tags:"
        puts JSON.pretty_generate(order["tags"].as_json)
        puts "_____"
        puts "NOW IDENTIFYING ATTRIBUTES FOR EACH ITEM"
        # call function for getting each item

        # orders_for_csv.push(new_order)
      end
      # orders_for_csv
    end


###########

      # single_order = my_orders[4].attributes
      # single_order.each do |myord|
      #     puts myord.inspect
      #     if myord[0] == "line_items"
      #         single_line_item = myord[1]
      #     end
      # end

    #   single_line_item.each do |mys|
    #       myjson = mys.attributes
    #       puts JSON.pretty_generate(myjson)
    #       myprops = mys.attributes['properties']
    #       myprops.each do |myprop|
    #           puts myprop.inspect
    #       end
    #   end
    # end
#########

    # def get_items
    # end

    def generate_csv_file
      current_date = DateTime.now
      rand_num_addon = rand(0..200).to_s
      # name of CSV file to write to
      name = "TEST_Orders" + current_date.strftime("_%^B%Y") + rand_num_addon + ".csv"
      name
    end

    # IMPORTANT INDICES REFERENCE:
    # 0 order number
    # 2 order date
    # 3 merchant sku
    # 4 quantity requested
    # 6 customer name
    # 7 shipping address
    # 8 shipping address2
    # 9 shipping address city
    # 10 shipping address state
    # 11 shipping address zipcode
    # 12 shipping address country
    # 23 item name
    # 24 vendor id
    # 27 billing name
    # 28 billing address
    # 29 billing city
    # 30 billing state
    # 31 billing zip
    # 32 billing country
    # 34 product weight (only for boxes)
    # 35 product weight unit
    # 40 customer phone number
    # 46 sell price

    def write_to_csv(orders)
      filename = generate_csv_file
      CSV.open(filename,"w+") do |file|
        file << header_arr
        orders.each do |order|
          data_out = []

          order["line_items"].each do |item|
            # new_item =
          end

          data_out[0] = order["unique_order_number"]
          data_out[2] =
          data_out[3] =
          data_out[4] =
          data_out[6] =
          data_out[7] = order["shipping_address"]
          data_out[8] = order["shipping_address2"]
          data_out[9] = order["shipping_city"]
          data_out[10] = order["shipping_state"]
          data_out[11] = order["shipping_zip"]
          data_out[12] = order["shipping_country"]
          data_out[23] =
          data_out[24] =
          data_out[27] = order["billing_customer_name"]
          data_out[28] = order["billing_address"]
          data_out[29] = order["billing_city"]
          data_out[30] = order["billing_state"]
          data_out[31] = order["billing_zip"]
          data_out[32] = order["billing_country"]
          data_out[34] =
          data_out[35] =
          data_out[40] = order["phone"]
          data_out[46] = order["total_price"]

          file << data_out
        end
      end

    end

###########
      #   orders.each do |order|

      #
      #       data_out = [
      #         order.order_number,
      #         "",
      #         "",
      #         item["sku"],
      #         1,
      #         "",
      #         order.influencer.first_name + " " + order.influencer.last_name,
      #         order.influencer.address1,
      #         order.influencer.address2,
      #         order.influencer.city,
      #         order.influencer.state,
      #         order.influencer.zip,
      #         "US",
      #         "FALSE",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         item["title"],
      #         "",
      #         "",
      #         "",
      #         order.influencer.first_name + " " + order.influencer.last_name,
      #         order.influencer.address1,
      #         order.influencer.city,
      #         order.influencer.state,
      #         order.influencer.zip,
      #         "US",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         order.influencer.phone,
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         0.00,
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         "",
      #         " \n"
      #       ]
      #       p "DATA OUT:"
      #       p data_out
      #       file << data_out
      #     end
      #   end
      #end

    header_arr = ["order_number","groupon_number","order_date","merchant_sku_item","quantity_requested","shipment_method_requested","shipment_address_name","shipment_address_street","shipment_address_street_2","shipment_address_city","shipment_address_state","shipment_address_postal_code","shipment_address_country","gift","gift_message","quantity_shipped","shipment_carrier","shipment_method","shipment_tracking_number","ship_date","groupon_sku","custom_field_value","permalink","item_name","vendor_id","salesforce_deal_option_id","groupon_cost","billing_address_name","billing_address_street","billing_address_city","billing_address_state","billing_address_postal_code","billing_address_country","purchase_order_number","product_weight","product_weight_unit","product_length","product_width","product_height","product_dimension_unit","customer_phone","incoterms","hts_code","3pl_name","3pl_warehouse_location","kitting_details","sell_price","deal_opportunity_id","shipment_strategy","fulfillment_method","country_of_origin","merchant_permalink","feature_start_date","feature_end_date","bom_sku","payment_method","color_code","tax_rate","tax_price\n"]

#   end   --> for class
# end     --> for module


create_orders
