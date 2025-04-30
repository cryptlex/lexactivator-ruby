require "./LexActivator"
require "./LexStatusCodes"
require 'json'


# Refer to following link for LexActivator API docs:
# https://github.com/cryptlex/lexactivator-c/blob/master/examples/LexActivator.h

def init()
  
  status = LexActivator.SetProductData(LexActivator::encode_utf16("PASTE_YOUR_PRODUCT_DATA"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetProductId(LexActivator::encode_utf16("PASTE_YOUR_PRODUCT_ID"), LexActivator::PermissionFlags::LA_USER)
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetReleaseVersion(LexActivator::encode_utf16("1.0.0"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end
end

def activate()
  status = LexActivator.SetLicenseKey(LexActivator::encode_utf16("PASTE_YOUR_LICENSE_KEY"))
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

# License callback (optional)
LicenseCallback = FFI::Function.new(:void, [:uint]) do |status|
  puts "License status: #{status}"
end

# Run it
init()
activate()

puts "Press Enter to exit..."
gets
