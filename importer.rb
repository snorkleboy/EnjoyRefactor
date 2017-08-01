def import(file, partner)

  raise if filepath[-3..-1] != 'csv'

  CSV.foreach(filepath, headers: true, header_converters: CSV::HeaderConverters[:symbol]) do |row|
    order = Order.find_or_initialize_by(partner_order_number: row["order_number"])
    location = Location.find_by(location_number: row["location_number"])
    customer = Customer.find_by(email: customer_profile.customer_id)
    billing_address = customer.billing_address

    if billing_address.street_address = row["shipping_address1"] &&
       billing_address.city = row["shipping_city"] &&
       billing_address.zip = row["shipping_zip"]

       shipping_address = billing_address

    elsif !row["shipping_address1"].blank? &&
        !row["shipping_city"].blank?

      shipping_address.street_address = row["shipping_address1"]
      shipping_address.street_address_2 = row["shipping_address2"]
      shipping_address.city = row["shipping_city"]
      shipping_address.state = row["shipping_state"]
      shipping_address.country = row["shipping_country"]
      shipping_address.zip = row["shipping_zip"]

      shipping_address.save

    else
      shipping_address = nil
    end

    order.partner_order_number = row["order_number"]
    order.partner_id = partner.id
    order.customer_id = customer.id

    if !billing_address.blank?
      order.billing_address = billing_address
    end

    if !shipping_address.blank?
      order.shipping_address = shipping_address
    end

    order.save

    skus = row['skus']
    while skus.count(',') > 0
      i = skus.index(',')
      sku = skus[0...i]
      skus = skus[i+1..-1]

      if Product.find_by(sku: sku)
        product = Product.find_by(sku: sku)
      else
        product = Product.new
        product.sku = sku
        product.save
      end

      order_item = OrderItem.new
      order_item.order_id = order.id
      order_item.product_id = product.id
      order_item.location_id = location.id
      order_item.save
    end
  end
end