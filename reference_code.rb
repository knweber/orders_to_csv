# Original CSV code:
def create_csv_file(ticket_id)

  header_arr = ["order_number","groupon_number","order_date","merchant_sku_item","quantity_requested","shipment_method_requested","shipment_address_name","shipment_address_street","shipment_address_street_2","shipment_address_city","shipment_address_state","shipment_address_postal_code","shipment_address_country","gift","gift_message","quantity_shipped","shipment_carrier","shipment_method","shipment_tracking_number","ship_date","groupon_sku","custom_field_value","permalink","item_name","vendor_id","salesforce_deal_option_id","groupon_cost","billing_address_name","billing_address_street","billing_address_city","billing_address_state","billing_address_postal_code","billing_address_country","purchase_order_number","product_weight","product_weight_unit","product_length","product_width","product_height","product_dimension_unit","customer_phone","incoterms","hts_code","3pl_name","3pl_warehouse_location","kitting_details","sell_price","deal_opportunity_id","shipment_strategy","fulfillment_method","country_of_origin","merchant_permalink","feature_start_date","feature_end_date","bom_sku","payment_method","color_code","tax_rate","tax_price\n"]

  @ticket = Ticket.find(ticket_id)
  orders = @ticket.orders

  CSV.open(@ticket.filename,'w+') do |file|
    file << header_arr
    orders.each do |order|

      influencer_id = order.influencer_id
      influencer = Influencer.find(influencer_id)

      p "_____ CURRENT ORDER:"
      p order
      p "_____ INFLUENCER ID:"
      p order.influencer_id


      order.line_items.as_json.each do |item|
        p "Current line item:"
        p item

        data_out = [
          order.order_number,
          "",
          "",
          item["sku"],
          1,
          "",
          order.influencer.first_name + " " + order.influencer.last_name,
          order.influencer.address1,
          order.influencer.address2,
          order.influencer.city,
          order.influencer.state,
          order.influencer.zip,
          "US",
          "FALSE",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          item["title"],
          "",
          "",
          "",
          order.influencer.first_name + " " + order.influencer.last_name,
          order.influencer.address1,
          order.influencer.city,
          order.influencer.state,
          order.influencer.zip,
          "US",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          order.influencer.phone,
          "",
          "",
          "",
          "",
          "",
          0.00,
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          " \n"
        ]
        p "DATA OUT:"
        p data_out
        file << data_out
      end
    end
  end
end

      # to download CSV
      get '/tickets/:id/download' do
        @ticket = Ticket.find(params[:id])
        p @ticket.filename
        create_csv_file(@ticket.id)
        send_file(@ticket.filename, :filename => @ticket.filename)
      end




# Original create_order code:

post '/orders' do
  # sample collection id for testing --> 19622330400 (August VIP)
  collection_id = params[:order][:collection_id]

  collection_addon = "/custom_collections/#{collection_id}.json"
  total = base_url + collection_addon
  collection = HTTParty.get(total)
  collection_name = collection["custom_collection"]["title"]

  puts "Chosen collection below:"
  puts "       " + collection_name
  puts " "

  # holds product type with corresponding title and product id
  collection_items = {}

  collection_items_addon = "/products.json?collection_id=#{collection_id}"
  total = base_url + collection_items_addon
  products = HTTParty.get(total)

  puts "Items in Collection:"

  products["products"].each do |prod|
    puts "  "

    collection_items[prod["product_type"]] = [prod["title"],prod["id"]]

    puts "       " + prod["title"] + ", " + prod["product_type"]
  end

  selected_items = []
  params[:order].keys.each do |item|
    if item != "collection_id" && collection_items[item]
      selected_items.push([item, collection_items[item]])
    end
  end
  p "*************"
  puts "Selected Items for Order:"
  p selected_items
  puts "__________"

  @new_ticket = Ticket.create

  Influencer.all.each do |user|
    order = Order.new({
      collection_id: collection_id,
      influencer_id: user.id,
      ticket_id: @new_ticket.id
    })
    if order.valid?
      order.save

      bra_size = user.bra_size
      top_size = user.top_size
      leggings_size = user.bottom_size
      jacket_size = user.sports_jacket_size

      ShopifyAPI::Base.site = "https://#{$apikey}:#{$password}@#{$shopname}.myshopify.com/admin"

      selected_items.each do |item|
        prod_type = item[0]
        prod_title = item[1][0]
        prod_id = item[1][1]

        p "*************"
        p "CURRENT ITEM:"
        p item

        var_for_prod = ShopifyAPI::Variant.where(product_id: prod_id)

        # product variants
        var_for_prod = var_for_prod.as_json

        var_id = ""
        var_sku = ""

        var_for_prod.each do |var|
          var_size = var["title"] # XS,S,M,L,XL
          if prod_type == "Leggings"
            if var_size == leggings_size
              var_id = var["id"]
              var_sku = var["sku"]
            end
          elsif prod_type == "Sports Bra"
            if var_size == bra_size
              var_id = var["id"]
              var_sku = var["sku"]
            end
          elsif prod_type == "Jacket"
            if var_size == jacket_size
              var_id = var["id"]
              var_sku = var["sku"]
            end
          elsif prod_type == "Tops"
            if var_size == top_size
              var_id = var["id"]
              var_sku = var["sku"]
            end
          elsif prod_type == "Wrap"
            if var_size == "ONE SIZE"
              var_id = var["id"]
              var_sku = var["sku"]
            end
          end
        end

        price_addon = "/variants/#{var_id}.json"

        total = base_url + price_addon
        price_response = HTTParty.get(total)
        var_price = price_response["variant"]["price"]

        item_for_influencer_order = LineItem.new({
          product_type: prod_type,
          title: prod_title,
          variant_id: var_id,
          product_id: prod_id,
          sku: var_sku,
          price: var_price,
          order_id: order.id
        })

        if item_for_influencer_order.valid?
          item_for_influencer_order.save
        else
          status 422
          p "Creation of line item failed"
          return erb :"uploads/new"
        end
      end
    end
  end

  # download output CSV
  # create_csv_file(@new_ticket.id)
  # send_file(new_ticket.filename)

  redirect "/tickets/#{@new_ticket.id}"
end
