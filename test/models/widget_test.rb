# frozen_string_literal: true

require 'test_helper'

class WidgetTest < ActiveSupport::TestCase
  setup do
    require 'app/models/widget'
    # Ensure table exists for tests
    begin
      Aws::Record::TableConfig.define { |t| t.model_class(Widget) }.migrate!
    rescue Aws::DynamoDB::Errors::ResourceInUseException
      # already exists
    end
  end

  test 'create and find widget' do
    id = SecureRandom.uuid
    w = Widget.new(id: id, name: 'Test')
    w.save!

    found = Widget.find(id: id)
    assert_not_nil found
    assert_equal 'Test', found.name

    found.delete!
    assert_nil Widget.find(id: id)
  end
end
