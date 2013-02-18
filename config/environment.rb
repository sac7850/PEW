# Load the rails application
require File.expand_path('../application', __FILE__)

if Rails.env.test?
  ENV["SALESFORCE_USERNAME"] = "username"
  ENV["SALESFORCE_PASSWORD"] = "password"
  ENV["SALESFORCE_SECURITY_TOKEN"] = "KYkNGSGF8VFfXwSalHdtjsLr"
  ENV["SALESFORCE_HOST"] = "test.salesforce.com"
end

if Rails.env.development?
  ENV["SALESFORCE_USERNAME"] = "username"
  ENV["SALESFORCE_PASSWORD"] = "password"
  ENV["SALESFORCE_SECURITY_TOKEN"] = "KYkNGSGF8VFfXwSalHdtjsLr"
  ENV["SALESFORCE_HOST"] = "test.salesforce.com"
end

if Rails.env.production?
  ENV["SALESFORCE_USERNAME"] = "username"
  ENV["SALESFORCE_PASSWORD"] = "password"
  ENV["SALESFORCE_SECURITY_TOKEN"] = "KYkNGSGF8VFfXwSalHdtjsLr"
  ENV["SALESFORCE_HOST"] = "test.salesforce.com"
end

# Initialize the rails application
ProfileEditWizard::Application.initialize!
