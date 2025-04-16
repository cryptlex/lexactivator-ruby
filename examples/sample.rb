require "./LexActivator"
require "./LexStatusCodes"
require 'json'


# Refer to following link for LexActivator API docs:
# https://github.com/cryptlex/lexactivator-c/blob/master/examples/LexActivator.h

def init()
  # status = LexActivator.SetProductFile("ABSOLUTE_PATH_OF_PRODUCT.DAT_FILE")
  status = LexActivator.SetProductData(LexActivator::encode_utf16("MTlERTdGMjBCNzk3QTA0RDI4OUEyNTlDNEIzNTUzNDI=.hRRwhtxjkpQiebQ2w3bW7S0ezkWZbvfdrnD00QyclPUolT1ZjeDujoSRE6uBMKtH7ZSxhf923nwdUg8aRQYlKoIXcRZt5DkjUC/mGap/r09JrQGJfEi0kjKwJkdgnT6zP/C+BXBibpyBpCFI9YDeLeOJbLvlpGoxPXfklUTavh0grpK8SrI939mOz4UoxBbs6FJ2/qnJQIBqbogb/QQ652iAIxlZhv2TmsgUWg65a0IPtBm7YIDt1Au4Ck94JyE6XeYbTAdgpv6Nzs2jasXfLGtNG9+mjWHFe/O3wdiCSSCqRBygMYvX1dx+d+LzJtmo8C8qoF2wCqfoHZ6TTCO5vfkpSHsbkDgV63H+5sLIOgT/o7mrzbSNlT7iG484w+9AePFFrQakCVvFleGXIlLChNaX0iWLDzLoTofc3q4ZAnPijTeCEPwpdPyUy37ilj7GzSb07BTZwqUItsxLAAgU5483gGGxQieRXUmkNP6KojtI3aISVBb96uIB+c69wxKEzhzLK9pZms/388vkLSoJ7d5ginP6gd8UdqH617X6IC8uz82+Lh83ER9lagSd9K6E6wtleEWixYyfMHbU20AUnqUjVKcTmaseqJeqfvpoPf/AoBrX870teAInOJXaWus350lALxMJO1lM1gtGOXdB6JoeFhodbRp7Kh6FFxkN8IO/hIB8Lh12yp5z/AZgboiNkYNswx3LA4r1Y/bZoCdQwoCZpzRbG6s3gg2zb0ziecwz6nEU2ESxNbgOQb8Wk8CsJFathNLmudEzxmtYwCjiq4Ncx993GpTIwYjenauh1amisumajsh99V0QDCLUqPhJ"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetProductId(LexActivator::encode_utf16("d121bd35-dc68-4bb1-87a4-de93bcf35bd9"), LexActivator::PermissionFlags::LA_USER)
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetAppVersion(LexActivator::encode_utf16("PASTE_YOUR_APP_VERION"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end
end

def activate()
  status = LexActivator.SetLicenseKey(LexActivator::encode_utf16("138402-09D63D-4181AA-0EB1E2-1970B1-E8BD34"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetActivationMetadata(LexActivator::encode_utf16("key1"), LexActivator::encode_utf16("value1"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.ActivateLicense()
  if [LexStatusCodes::LA_OK, LexStatusCodes::LA_EXPIRED, LexStatusCodes::LA_SUSPENDED].include?(status)
    puts "License activated successfully: #{status}"
  else
    puts "License activation failed: #{status}"
    exit(status)
  end
end

def fetch_entitlements()
  # Get License Entitlement Set Name
  buffer = "\0" * 256
  status = LexActivator.GetLicenseEntitlementSetName(buffer, buffer.length)
  if status == LexStatusCodes::LA_OK
    puts "Entitlement Set Name: #{buffer.strip}"
  else
    puts "Failed to get entitlement set name. Status code: #{status}"
  end

  # Get License Entitlement Set Display Name
  buffer = "\0" * 256
  status = LexActivator.GetLicenseEntitlementSetDisplayName(buffer, buffer.length)
  if status == LexStatusCodes::LA_OK
    puts "Entitlement Set Display Name: #{buffer.strip}"
  else
    puts "Failed to get entitlement set display name. Status code: #{status}"
  end

  # Get all Feature Entitlements
  buffer = "\0" * 4096
  status = LexActivator.GetFeatureEntitlements(buffer, buffer.length)
  if status == LexStatusCodes::LA_OK
    entitlement_list = buffer.strip
puts "Feature Entitlements:"
entitlement_list.split(',').each do |ent|
  puts "Name: #{ent.strip}"
end

  else
    puts "Failed to get feature entitlements. Status code: #{status}"
  end

  # Get a specific Feature Entitlement (optional)
  feature_name = LexActivator.encode_utf16("LOGS")  # replace with your actual feature name
  buffer = "\0" * 4096
  status = LexActivator.GetFeatureEntitlement(feature_name, buffer, buffer.length)
  if status == LexStatusCodes::LA_OK
    entitlement = JSON.parse(buffer.strip)
    puts "Feature Entitlement for 'LOGS':"
    puts "Name: #{entitlement["featureName"]}, Value: #{entitlement["value"]}"
  else
    puts "Feature Entitlement for 'LOGS' not found. Status code: #{status}"
  end
end

# License callback (optional)
LicenseCallback = FFI::Function.new(:void, [:uint]) do |status|
  puts "License status: #{status}"
end

# Run it
init()
activate()
fetch_entitlements()

puts "Press Enter to exit..."
gets
