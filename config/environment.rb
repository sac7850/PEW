# Load the rails application
require File.expand_path('../application', __FILE__)

if Rails.env.test?
  ENV["SALESFORCE_USERNAME"] = "stacy_crochet@schumachergroup.com.stacydev"
  ENV["SALESFORCE_PASSWORD"] = "Summer11"
  ENV["SALESFORCE_SECURITY_TOKEN"] = "KYkNGSGF8VFfXwSalHdtjsLr"
  ENV["SALESFORCE_HOST"] = "test.salesforce.com"
end

if Rails.env.development?
  ENV["SALESFORCE_USERNAME"] = "stacy_crochet@schumachergroup.com.stacydev"
  ENV["SALESFORCE_PASSWORD"] = "Summer11"
  ENV["SALESFORCE_SECURITY_TOKEN"] = "KYkNGSGF8VFfXwSalHdtjsLr"
  ENV["SALESFORCE_HOST"] = "test.salesforce.com"
end

if Rails.env.production?
  ENV["SALESFORCE_USERNAME"] = "stacy_crochet@schumachergroup.com.stacydev"
  ENV["SALESFORCE_PASSWORD"] = "Summer11"
  ENV["SALESFORCE_SECURITY_TOKEN"] = "KYkNGSGF8VFfXwSalHdtjsLr"
  ENV["SALESFORCE_HOST"] = "test.salesforce.com"
end

# Initialize the rails application
ProfileEditWizard::Application.initialize!
