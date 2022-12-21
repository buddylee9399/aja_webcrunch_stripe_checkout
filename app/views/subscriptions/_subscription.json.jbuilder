json.extract! subscription, :id, :plan_id, :customer_id, :user_id, :status, :interval, :subscription_id, :current_period_start, :current_period_end, :created_at, :updated_at
json.url subscription_url(subscription, format: :json)
