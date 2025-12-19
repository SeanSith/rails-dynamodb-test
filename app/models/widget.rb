# frozen_string_literal: true

class Widget
  include Aws::Record

  string_attr :id, hash_key: true
  string_attr :name

  set_table_name :widgets

  # Configure client in dev/test using initializer constant if available.
  if defined?(DYNAMODB_CLIENT)
    configure_client(client: DYNAMODB_CLIENT)
  end
end
