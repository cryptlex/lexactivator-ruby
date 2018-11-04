require "./LexActivator"
require "./LexStatusCodes"

# Refer to following link for LexActivator API docs:
# https://github.com/cryptlex/lexactivator-c/blob/master/examples/LexActivator.h

def init()
  # status = LexActivator.SetProductFile("ABSOLUTE_PATH_OF_PRODUCT.DAT_FILE")
  status = LexActivator.SetProductData("PASTE_CONTENT_OF_PRODUCT.DAT_FILE")
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetProductId("PASTE_PRODUCT_ID", LexActivator::PermissionFlags::LA_USER)
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetAppVersion("PASTE_YOUR_APP_VERION")
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end
end

def activate()
  status = LexActivator.SetLicenseKey("PASTE_LICENCE_KEY")
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  status = LexActivator.SetActivationMetadata("key1", "value1")
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
  status = LexActivator.SetTrialActivationMetadata("key1", "value1")
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
  # email = String.new(256)  # ruby >= 2.4
  email = " " * 256
  LexActivator.GetLicenseUserEmail(email, 256)
  #   puts "License user email: #{email.read_string}"
  puts "License user email: #{email.rstrip}"

  puts "License is genuinely activated!"
elsif LexStatusCodes::LA_EXPIRED == status
  puts "License is genuinely activated but has expired!"
elsif LexStatusCodes::LA_SUSPENDED == status
  puts "License is genuinely activated but has been suspended!"
elsif LexStatusCodes::LA_GRACE_PERIOD_OVER == status
  puts "License is genuinely activated but grace period is over!"
else
  trialStatus = LexActivator.IsTrialGenuine()
  if LexStatusCodes::LA_OK == trialStatus
    # const trialExpiryDate = ref.alloc(ref.types.uint32)
    # LexActivator.GetTrialExpiryDate(trialExpiryDate)
    # const daysLeft = (trialExpiryDate.deref() - (new Date().getTime() / 1000)) / 86500
    # puts "Trial days left:", daysLeft)
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
