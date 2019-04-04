require "./LexActivator"
require "./LexStatusCodes"

# Refer to following link for LexActivator API docs:
# https://github.com/cryptlex/lexactivator-c/blob/master/examples/LexActivator.h

def init()
  # status = LexActivator.SetProductFile("ABSOLUTE_PATH_OF_PRODUCT.DAT_FILE")
  status = LexActivator.SetProductData(LexActivator::encode_utf16("PASTE_CONTENT_OF_PRODUCT.DAT_FILE"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetProductId(LexActivator::encode_utf16("PASTE_PRODUCT_ID"), LexActivator::PermissionFlags::LA_USER)
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
  status = LexActivator.SetLicenseKey(LexActivator::encode_utf16("PASTE_LICENSE_KEY"))
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
  if LexStatusCodes::LA_OK == status || LexStatusCodes::LA_EXPIRED == status || LexStatusCodes::LA_SUSPENDED == status
    puts "License activated successfully: #{status}"
  else
    puts "License activation failed: #{status}"
  end
end

def activate_trial()
  status = LexActivator.SetTrialActivationMetadata(LexActivator::encode_utf16("key1"), LexActivator::encode_utf16("value1"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.ActivateTrial()
  if LexStatusCodes::LA_OK == status
    puts "Product trial activated successfully!"
  elsif LexStatusCodes::LA_TRIAL_EXPIRED == status
    puts "Product trial has expired!"
  else
    puts "Product trial activation failed: #{status}"
  end
end

LicenseCallback = FFI::Function.new(:void, [:uint]) do |status|
  puts "License status: #{status}"
end

SoftwareReleaseUpdateCallback = FFI::Function.new(:void, [:uint]) do |status|
  puts "Release status: #{status}"
end

init()
# activate()
LexActivator.SetLicenseCallback(LicenseCallback)
status = LexActivator.IsLicenseGenuine()
if LexStatusCodes::LA_OK == status
  # get days left for expiry
  expiryDate = FFI::MemoryPointer.new(:uint)
  LexActivator.GetLicenseExpiryDate(expiryDate)
  daysLeft = (expiryDate.read_int - Time.now.to_i) / 86500
  puts "Days left: #{daysLeft}"

  # get license user email
  buffer = FFI::MemoryPointer.new(:char, 256)
  LexActivator.GetLicenseUserEmail(buffer, buffer.size)
  email = LexActivator::decode_utf16(buffer.read_string(buffer.size).rstrip)
  puts "License user email: #{email}"
  puts "License is genuinely activated!"

  # puts "Checking for software release update..."
  # status = LexActivator.CheckForReleaseUpdate("windows", "1.0.0", "stable", SoftwareReleaseUpdateCallback)
  # if LexStatusCodes::LA_OK != status
  #   puts "Error checking for software release update: #{status}"
  # end
elsif LexStatusCodes::LA_EXPIRED == status
  puts "License is genuinely activated but has expired!"
elsif LexStatusCodes::LA_SUSPENDED == status
  puts "License is genuinely activated but has been suspended!"
elsif LexStatusCodes::LA_GRACE_PERIOD_OVER == status
  puts "License is genuinely activated but grace period is over!"
else
  trialStatus = LexActivator.IsTrialGenuine()
  if LexStatusCodes::LA_OK == trialStatus
    # get days left for expiry
    trialExpiryDate = FFI::MemoryPointer.new(:uint)
    LexActivator.GetTrialExpiryDate(trialExpiryDate)
    daysLeft = (trialExpiryDate.read_int - Time.now.to_i) / 86500
    puts "Trial days left: #{daysLeft}"
  elsif LexStatusCodes::LA_TRIAL_EXPIRED == trialStatus
    puts "Trial has expired!"
    # Time to buy the license and activate the app
    activate()
  else
    puts "Either trial has not started or has been tampered!"
    # Activating the trial
    activate_trial()
  end
end
