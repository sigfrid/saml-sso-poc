require 'bundler'
Bundler.require

def saml_settings
  settings = OneLogin::RubySaml::Settings.new

  # When disabled, saml validation errors will raise an exception.
  # settings.soft = true

  #SP section
  settings.sp_entity_id                   = ENV['URL_BASE'] + "/saml/metadata"
  settings.assertion_consumer_service_url = ENV['URL_BASE'] + "/saml/acs"
  settings.assertion_consumer_logout_service_url = ENV['URL_BASE'] + "/saml/logout"

  # IdP section
  settings.idp_entity_id                  = "https://sts.windows.net/#{ENV['MICROSOFT_APP_ID']}/"
  settings.idp_sso_target_url             = "https://login.microsoftonline.com/#{ENV['MICROSOFT_APP_ID']}/saml2"
  settings.idp_slo_target_url             = "https://login.microsoftonline.com/#{ENV['MICROSOFT_APP_ID']}/saml2"
  ####settings.idp_cert                       = ""
  settings.idp_cert_fingerprint           = "361F0706F00F9558CA9D71E5110B1A71A36DBCA8"
  settings.idp_cert_fingerprint_algorithm =  XMLSecurity::Document::SHA1 #"http://www.w3.org/2000/09/xmldsig#sha1"


  settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

  # Security section
  settings.security[:authn_requests_signed] = false
  settings.security[:logout_requests_signed] = false
  settings.security[:logout_responses_signed] = false
  settings.security[:metadata_signed] = false
  settings.security[:digest_method] = XMLSecurity::Document::SHA1
  settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1

  return settings
end

post '/saml/metadata' do
  content_type 'text/xml'
  OneLogin::RubySaml::Metadata.new.generate(saml_settings)
end

post '/saml/acs' do
  response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
  response.settings = saml_settings

  # We validate the SAML Response and check if the user already exists in the system
  if response.is_valid?
    # authorize_success, log the user
    p "VALID !!!!!"
    @nameid = response.nameid
    # p response.attributes
    erb :in
  else
    p " FAILURE"
    @errors = response.errors
    erb :out
      # List of errors is available in response.errors array
  end
end

get '/' do
  request = OneLogin::RubySaml::Authrequest.new
  redirect request.create(saml_settings)
end
