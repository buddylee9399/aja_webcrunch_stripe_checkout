# web crunch - stripe checkout
- https://www.youtube.com/watch?v=bJtgeXtrXT4
- GEMS
```
group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem 'better_errors'
  gem 'binding_of_caller', '~> 1.0'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

# gem "sidekiq"
# gem "cssbundling-rails"
gem "devise"
gem "friendly_id"
gem "name_of_person"
gem "pay"
gem "stripe"
```
- created a monthly and a yearly
- install tailwind
- https://tailwindcss.com/docs/guides/ruby-on-rails
- add to layout app
```
<%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
```
- bundle
- rails g controller home index
- update routes

```
root to: 'home#index'
```
- copied over his home index to test tailwind
- bin/dev
- rails active_storage:install
- rails action_text:install
- rails g devise:install
- rails g devise:views
- rails g devise User first_name last_name admin:boolean
- update migration
```
t.boolean :admin, default: false
```
- rails db:migrate
- update routes: this is to scope for admins boolean true

```
  authenticate :user, lambda { |u| u.admin? } do
    # mount Sidekiq::Web => '/sidekiq'
  end
```
- rails 7 update app controller

```
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    end

end

```
- rails g controller static pricing
- update routes

```
  scope controller: :static do
    get :pricing
  end
```

- copy over his pricing page
- copied his app.html and shared folder
- copied his app helper classes

```
  def flash_classes(flash_type)
    flash_base = "px-2 py-4 mx-auto font-sans font-medium text-center text-white"
    {
      notice: "bg-indigo-600 #{flash_base}",
      error:  "bg-red-600 #{flash_base}",
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def nav_classes
    ["devise/registrations", "devise/sessions", "devise/confirmations", "devise/passwords", "devise/unlocks"].include?(params[:controller]) ? "hidden" : nil
  end

  def label_class(options={})
    "block mb-1 font-normal leading-normal #{options[:extended_classes]}"
  end

  def input_class(options={})
    "rounded border border-gray-300 block w-full focus:outline-none focus:border-gray-400 outline-none focus-within:outline-none focus:ring-2 focus:ring-gray-200 #{options[:extended_classes]}"
  end

  def checkbox_class(options={})
    "rounded border-gray-300 border focus:ring-2 focus:ring-gray-200 text-blue-500 mr-1 #{options[:extended_classes]}"
  end

  def link_class(options={})
    "text-gray-700 underline hover:no-underline hover:text-gray-800 block #{options[:extended_classes]}"
  end

  def button_class(options={})
    variant = options[:variant]
    theme = options[:theme]

    style_button(variant, theme_button(theme))
  end

  def theme_button(theme)
    themes = {
      primary: "primary",
      secondary: "secondary",
      transparent: "transparent",
      dark: "dark"
    }

    case theme
    when themes[:primary]
      "bg-indigo-600 hover:bg-indigo-700 text-white"
    when themes[:secondary]
      "bg-teal-600 hover:bg-teal-700 text-white"
    when themes[:transparent]
      "bg-transparent hover:bg-gray-100 text-gray-700"
    when themes[:dark]
      "bg-gray-800 text-white shadow-sm hover:bg-gray-900"
    else
      "bg-white border border-gray-300 shadow-sm hover:bg-gray-100"
    end
  end

  def style_button(variant, theme)
    base = "rounded text-center font-sans font-normal outline-none leading-normal cursor-pointer transition ease-in-out duration-200 font-medium"

    case variant
    when "large"
      "px-5 py-4 text-lg #{base} #{theme}"
    when "small"
      "py-2 px-4 text-sm #{base} #{theme}"
    when "expanded"
      "p-3 w-full block #{base} #{theme}"
    else
      "px-5 py-2 text-base #{base} #{theme}"
    end
  end
end

```
- copied over devise views
- add to user.rb:   has_person_name ; to use the name field in devise adding up first and last name
- refreshed and the pages were there
- ADDING STRIPE
- for the pay gem
- rails pay:install:migrations
- rails db:migrate
```
# config/application.rb
config.action_mailer.default_url_options = { host: "example.com" }
```
- update user.rb
```
pay_customer
```
- rails g scaffold subscription plan_id customer_id user:references status interval subscription_id current_period_start:datetime current_period_end:datetime
- rails db:migrate
- update user.rb

```
  pay_customer

  has_person_name

  has_many :subscriptions, dependent: :destroy
```

- rails g migration AddStripeIdToUsers stripe_id
- rails db:migrate
- update routes

```
  namespace :purchase do
    resources :checkouts
  end

  resources :subscriptions
```

- create the controllers/purchase folder with checkouts controller inside

```
class Purchase::CheckoutsController < ApplicationController
  before_action :authenticate_user!

  def create
    price = params[:price_id]

    session = Stripe::Checkout::Session.create(
      customer: current_user.stripe_id,
      client_reference_id: current_user.id,
      success_url: root_url + "success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: pricing_url,
      payment_method_types: ['card'],
      mode: 'subscription',
      customer_email: current_user.email,
      line_items: [{
        quantity: 1,
        price: price
      }]
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @customer = Stripe::Customer.retrieve(session.customer)
  end
end

```

- editing the credentials

```
EDITOR="subl --wait" rails credentials:edit

development:
  stripe:
    # publication key:
    public_key: 1234
    # secret key:
    private_key: 12341234
    signing_secret: 123412341234
    pricing:
    	monthly: 12341234
    	yearly: 12341234
```

- testing to see if stripe is connected

```
- rails c
- Rails.application.credentials[:development][:stripe][:private_key]
- list = Stripe::Customer.list() - to see if it works- IT WORKS
```
- BOTH WORKED
- add to layouts/app via shared/head
```
<%= javascript_include_tag 'https://js.stripe.com/v3/', 'data-turbolinks-track': 'reload' %>
```

- he then added the stripe key to app controller, but i think with pay gem we dont have to do that

```
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_stripe_key

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    end

  private

    def set_stripe_key
      Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
    end
end
```

- updated the pricing page with the monthly and yearly credentials
- refresh and tested it out, it got redirected to stripe checkout
- update routes

```
get "success", to: "purchase/checkouts#success"
```

- add the view purchase/checkouts/success
- update checouts controller

```
  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @customer = Stripe::Customer.retrieve(session.customer)
  end
```

- refresh and sign up
- IT WORKED
- adding webhooks
- add to procfile

```
stripe: stripe listen --forward-to localhost:3000/pay/webhooks/stripe 
```

- restart server
- he does webhooks controller, thats where the logic to give the user a subscription through there and write to the subscription model in the database:
```
rails g controller webhooks - i copied his over just to have it
//routes.rb
resources :webhooks, only: :create

then he did the billings to update the subscription
did a subscriptions mailer
```

## THE END