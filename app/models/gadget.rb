# frozen_string_literal: true

class Gadget
  include Aws::Record

  string_attr :id, hash_key: true
  string_attr :version, range_key: true
  string_attr :name

  set_table_name :gadgets

  if defined?(DYNAMODB_CLIENT)
    configure_client(client: DYNAMODB_CLIENT)
  end
end
