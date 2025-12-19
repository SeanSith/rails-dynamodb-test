# require 'aws-sdk-dynamodb'
# require 'aws-record'

# Use local DynamoDB only in dev/test. Production uses default AWS config.
if defined?(Rails) && (Rails.env.development? || Rails.env.test?)
  DYNAMODB_CLIENT = Aws::DynamoDB::Client.new(
    region: ENV.fetch('AWS_REGION', 'us-east-1'),
    endpoint: ENV.fetch('DYNAMODB_ENDPOINT', 'http://localhost:8000'),
    credentials: Aws::Credentials.new(
      ENV.fetch('AWS_ACCESS_KEY_ID', 'fake'),
      ENV.fetch('AWS_SECRET_ACCESS_KEY', 'fake')
    )
  )

  # Optionally set global defaults so bare clients also work.
  Aws.config.update(
    region: ENV.fetch('AWS_REGION', 'us-east-1'),
    credentials: Aws::Credentials.new(
      ENV.fetch('AWS_ACCESS_KEY_ID', 'fake'),
      ENV.fetch('AWS_SECRET_ACCESS_KEY', 'fake')
    ),
    endpoint: ENV.fetch('DYNAMODB_ENDPOINT', 'http://localhost:8000')
  )
end
