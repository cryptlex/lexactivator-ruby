require "./LexActivator"
require "./LexStatusCodes"


# Refer to following link for LexActivator API docs:
# https://github.com/cryptlex/lexactivator-c/blob/master/examples/LexActivator.h

def init()
  
  status = LexActivator.SetProductData(LexActivator::encode_utf16("QkZFOTFCQjgyNDcxQjAwOTQ0N0EwMjQ2MTFBNEU4MTU=.cDgL9zxFNkVRa473ZM0i7RaD3xUDpoSQDpzzLcZP8oHkSwv8aheQM0BFCWei9cTswbTBKAhd3tK6ikgmYBudgynbEse6tqBXtbYC6hG6JaRxboOPG51gcoYU9z9nIGXARML3tXyX1tm+esNieQqbR/TUA9zxf9LXfcy7uWY/6Pj1qXPqKaQupsQSJbZfvNrFVmvZqeMfVPqzWB0xaVAoo40nxK/PbdSchU1Q6gRNTUqlZ64EhhYZAerzLv08/PjKPpFn5edC4jq9hmRzs2Du0g9T2O5igP4sk2Bkr8fH3086sSSRks0yIhqFiauM/jytq1EtiLwcbwaKudvkJDgBhZYYYuM5X3EutiZcZ9DmJljdghNWivuy/WCSbBYvs1Rm+ikkUeFRckc9TGHvVCSaIZ115LU5IBmxGdRFEsvlh+oAW4zoJ2Uus8z92LF1c3vsGoa8G2O7XMP+eacTEkJ2yOCAOz/ERZn9duaPGmtDYrmGilHFdQht+J2DeC9sdtBMQu17+M8PwEZvQzBG+WV3uGdgQz1eptZ/g4BNf45B50auCuCUGGilog3fvdWThrFO4RUaZAYs8Mv2qrZULxM19tfFdGfYXghNZM1UHbNCvbJaXFEGL/ZaesGhyAtY0w+zQu+GdCchd3ZpvHGxKZU7U6LLoSu0YzUF56QDTKqBZrqEmz0OgQHBWTNxLpOOI/uDKBzvjKxCYZAtxrc/KjZ2/d+6vlZR/R2elRg5qv5YtOC74vHut/u50cz+kez++1q/jTnLsNVG0+V+lsP4sR3rcAYsJzRmfOmDER0YDnPiQgK6RbarcWpARcIvamHnW3Lc"))
  if LexStatusCodes::LA_OK != status
    puts "Error Code: #{status}"
    exit(status)
  end

  LexActivator.MigrateToSystemWideActivation(LexActivator::PermissionFlags::LA_USER)
  status = LexActivator.SetProductId(LexActivator::encode_utf16("01997b28-eeb0-7fcb-aab2-a6bf4a2f6fc3"), LexActivator::PermissionFlags::LA_ALL_USERS)
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
  status = LexActivator.SetLicenseKey(LexActivator::encode_utf16("655C33-0A3B2B-489DB0-732044-CAF5D3-952D87"))
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

# License callback (optional)
LicenseCallback = FFI::Function.new(:void, [:uint]) do |status|
  puts "License status: #{status}"
end

SoftwareReleaseUpdateCallback = FFI::Function.new(:void, [:uint]) do |status|
  puts "Release status: #{status}"
end

# Run it
init()
#activate() # uncomment this to activate the license
LexActivator.SetLicenseCallback(LicenseCallback)
status = LexActivator.IsLicenseGenuine()
if LexStatusCodes::LA_OK == status
  # get days left for expiry
  expiryDate = FFI::MemoryPointer.new(:uint)
  LexActivator.GetLicenseExpiryDate(expiryDate)
  daysLeft = (expiryDate.read_int - Time.now.to_i) / 86400
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

puts "Press Enter to exit..."
gets
