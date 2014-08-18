require 'sinatra'
require 'json'
require 'rest-client'

APP_ID       = "example-app-id"
APP_SECRET   = "example-app-secret"
CUSTOMER_URL = "https://www.saltedge.com/api/v1/customers/"

def create_customer(email)
  RestClient::Request.execute(
    :method => :post,
    :url    => CUSTOMER_URL,
    :headers => {
      :content_type => :json,
      :accept       => :json,
      :"App-id"     => APP_ID,
      :"App-secret" => APP_SECRET
    },
    :timeout => 300,
    :payload => {
      :data => {
        :email => email
      }
    }
  )
end

post "/customers" do
  content_type :json
  create_customer(params["email"])
end
