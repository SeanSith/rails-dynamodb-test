# frozen_string_literal: true

namespace :dynamodb do
  desc 'Check DynamoDB connectivity (lists tables)'
  task check: :environment do
    client = Aws::DynamoDB::Client.new(
      region: ENV.fetch('AWS_REGION', 'us-east-1'),
      endpoint: ENV.fetch('DYNAMODB_ENDPOINT', 'http://localhost:8000'),
      credentials: Aws::Credentials.new(
        ENV.fetch('AWS_ACCESS_KEY_ID', 'fake'),
        ENV.fetch('AWS_SECRET_ACCESS_KEY', 'fake')
      )
    )
    tables = client.list_tables.table_names
    puts "DynamoDB reachable. Tables: #{tables.any? ? tables.join(', ') : '(none)'}"
  rescue => e
    warn "DynamoDB check failed: #{e.class}: #{e.message}"
    raise
  end

  namespace :widgets do
    desc 'Create widgets table in local DynamoDB'
    task create_table: :environment do
      cfg = Aws::Record::TableConfig.define do |t|
        t.model_class(Widget)
        t.read_capacity_units(5)
        t.write_capacity_units(5)
      end

      cfg.migrate!
      puts 'Created/validated widgets table.'
    rescue Aws::DynamoDB::Errors::ResourceInUseException
      puts 'Widgets table already exists.'
    end

    desc 'Demo CRUD operations with Widget model'
    task demo: :environment do
      # Ensure table exists
      begin
        Aws::Record::TableConfig.define do |t|
          t.model_class(Widget)
          t.read_capacity_units(5)
          t.write_capacity_units(5)
        end.migrate!
      rescue Aws::DynamoDB::Errors::ResourceInUseException
        # ignore
      end

      id = SecureRandom.uuid
      w = Widget.new(id: id, name: 'Sample')
      w.save!
      puts "Saved widget #{id}"

      found = Widget.find(id: id)
      puts "Found widget: #{found&.id} name=#{found&.name}"

      found.delete!
      puts 'Deleted widget.'
    end
  end

  namespace :gadgets do
    desc 'Create gadgets table in local DynamoDB'
    task create_table: :environment do
      cfg = Aws::Record::TableConfig.define do |t|
        t.model_class(Gadget)
        t.read_capacity_units(5)
        t.write_capacity_units(5)
      end

      cfg.migrate!
      puts 'Created/validated gadgets table.'
    rescue Aws::DynamoDB::Errors::ResourceInUseException
      puts 'Gadgets table already exists.'
    end

    desc 'Batch write/read demo using Gadget'
    task batch_demo: :environment do
      # Ensure table exists
      begin
        Aws::Record::TableConfig.define do |t|
          t.model_class(Gadget)
          t.read_capacity_units(5)
          t.write_capacity_units(5)
        end.migrate!
      rescue Aws::DynamoDB::Errors::ResourceInUseException
      end

      g1 = Gadget.new(id: 'g1', version: 'v1', name: 'One')
      g2 = Gadget.new(id: 'g2', version: 'v1', name: 'Two')

      op = Aws::Record::Batch.write(client: Gadget.dynamodb_client) do |db|
        db.put(g1)
        db.put(g2)
      end
      op.execute! until op.complete?
      puts 'BatchWrite completed.'

      resp = Gadget.dynamodb_client.batch_get_item(
        request_items: {
          Gadget.table_name => {
            keys: [
              { 'id' => 'g1', 'version' => 'v1' },
              { 'id' => 'g2', 'version' => 'v1' }
            ]
          }
        }
      )
      items = resp.responses[Gadget.table_name] || []
      items.each do |attrs|
        g = Gadget.new(attrs)
        puts "Read: #{g.id} #{g.version} name=#{g.name}"
      end
    end

    desc 'Transaction demo across Widget and Gadget tables'
    task txn_demo: :environment do
      # Ensure tables exist
      [Widget, Gadget].each do |model|
        begin
          Aws::Record::TableConfig.define do |t|
            t.model_class(model)
            t.read_capacity_units(5)
            t.write_capacity_units(5)
          end.migrate!
        rescue Aws::DynamoDB::Errors::ResourceInUseException
        end
      end

      w = Widget.new(id: 'tx-w-1', name: 'TxWidget')
      g = Gadget.new(id: 'tx-g-1', version: 'v1', name: 'TxGadget')

      Aws::Record::Transactions.transact_write(
        transact_items: [
          { save: w },
          { save: g }
        ]
      )
      puts 'TransactWriteItems succeeded.'
    end
  end
end
