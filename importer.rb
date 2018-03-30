def import(file, partner, settings = nil)
  # Artem Kharshan
  # 03/30/2018
  # is filepath supposed to be the file parameter passed in?
  raise ArgumentError, 'file must be of filetype csv' if filepath[-3..-1] != 'csv'
  settings ||= {
    headers: true,
    header_converters: CSV::HeaderConverters[:symbol]
  }

  CSV.foreach(filepath, *settings) do |row|
    @customer = Customer.find_by(email: customer_profile.customer_id)
    billing_address, shipping_address = get_addresses(row)
    order = make_order(row, partner, billing_address, shipping_address)
    make_order_items(row['skus'], order)
  end
end

def get_addresses(row)
  billing_address = @customer.billing_address
  # Artem Kharshan
  # 03/30/2018
  # are these supposed to be assignments or comparisons? 
  if billing_address.street_address = row['shipping_address1'] &&
               billing_address.city = row['shipping_city'] &&
                billing_address.zip = row['shipping_zip']
    shipping_address = billing_address
  elsif !row['shipping_address1'].blank? &&
        !row['shipping_city'].blank?
    
    shipping_address.street_address = row['shipping_address1']
    shipping_address.street_address_2 = row['shipping_address2']
    shipping_address.city = row['shipping_city']
    shipping_address.state = row['shipping_state']
    shipping_address.country = row['shipping_country']
    shipping_address.zip = row['shipping_zip']

    shipping_address.save
  else
    shipping_address = nil
  end
  [billing_address, shipping_address]
end

def make_order(row, partner, billing_address, shipping_address)
  order = Order.find_or_initialize_by(partner_order_number: row['order_number'])
  order.partner_order_number = row['order_number']
  order.partner_id = partner.id
  order.customer_id = @customer.id 
  order.billing_address = billing_address unless billing_address.blank?
  order.shipping_address = shipping_address unless shipping_address.blank?
  order.save
  order
end

def make_order_items(skus,order)
  while skus.count(',') > 0
    i = skus.index(',')
    sku = skus[0...i]
    skus = skus[i + 1..-1]

    product = make_product(sku)
    location = Location.find_by(location_number: row['location_number'])
    order_item = OrderItem.new
    order_item.order_id = order.id
    order_item.product_id = product.id
    order_item.location_id = location.id
    order_item.save
  end
end

def make_product(sku)
  if Product.find_by(sku: sku)
    product = Product.find_by(sku: sku)
  else
    product = Product.new
    product.sku = sku
    product.save
  end
  product
end