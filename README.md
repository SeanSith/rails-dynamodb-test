# Rails + DynamoDB Test

This is a test of the aws-record gem in conjunction with Ruby on Rails.

## Setup

1. `docker compose up`
2. `bundle install`

```#ruby
AWS_SDK_LOAD_CONFIG=0 AWS_PROFILE= bundle exec rake dynamodb:widgets:create_table
AWS_SDK_LOAD_CONFIG=0 AWS_PROFILE= bundle exec rake dynamodb:gadgets:create_table
AWS_SDK_LOAD_CONFIG=0 AWS_PROFILE= bundle exec rails server -p 3000
```

## Test patterns
- Create via UI at /widgets and /gadgets, or curl:
  - curl -X POST -d 'name=FromCurl' http://localhost:3000/widgets
  - curl -X POST -d 'id=curl-g1&version=v2&name=GadgetFromCurl' http://localhost:3000/gadgets
