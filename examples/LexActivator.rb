require "ffi"

module LexActivator
  extend FFI::Library
  ffi_lib ["LexActivator", "./libLexActivator.so"]
  callback :license_callback, [:uint], :void

  def self.attach_function(name, *_)
    begin; super;     rescue FFI::NotFoundError => e
      (class << self; self; end).class_eval { define_method(name) { |*_| raise e } }
    end
  end

  module PermissionFlags
    LA_USER = 1
    LA_SYSTEM = 2
  end

  # @method SetProductFile(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :SetProductFile, :SetProductFile, [:string], :int

  # @method SetProductData(product_data)
  # @param [String] product_data
  # @return [Integer]
  # @scope class
  attach_function :SetProductData, :SetProductData, [:string], :int

  # @method SetProductId(product_id, flags)
  # @param [String] product_id
  # @param [Integer] flags
  # @return [Integer]
  # @scope class
  attach_function :SetProductId, :SetProductId, [:string, :uint], :int

  # @method SetLicenseKey(license_key)
  # @param [String] license_key
  # @return [Integer]
  # @scope class
  attach_function :SetLicenseKey, :SetLicenseKey, [:string], :int

  # @method SetLicenseCallback(callback)
  # @param [FFI::Pointer(CallbackType)] callback
  # @return [Integer]
  # @scope class
  attach_function :SetLicenseCallback, :SetLicenseCallback, [:license_callback], :int

  # @method SetActivationMetadata(key, value)
  # @param [String] key
  # @param [String] value
  # @return [Integer]
  # @scope class
  attach_function :SetActivationMetadata, :SetActivationMetadata, [:string, :string], :int

  # @method SetTrialActivationMetadata(key, value)
  # @param [String] key
  # @param [String] value
  # @return [Integer]
  # @scope class
  attach_function :SetTrialActivationMetadata, :SetTrialActivationMetadata, [:string, :string], :int

  # @method SetAppVersion(app_version)
  # @param [String] app_version
  # @return [Integer]
  # @scope class
  attach_function :SetAppVersion, :SetAppVersion, [:string], :int

  # @method SetNetworkProxy(proxy)
  # @param [String] proxy
  # @return [Integer]
  # @scope class
  attach_function :SetNetworkProxy, :SetNetworkProxy, [:string], :int

  # @method GetProductMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetProductMetadata, :GetProductMetadata, [:string, :string, :uint], :int

  # @method GetLicenseMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseMetadata, :GetLicenseMetadata, [:string, :string, :uint], :int

  # @method GetLicenseKey(license_key, length)
  # @param [String] license_key
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseKey, :GetLicenseKey, [:string, :uint], :int

  # @method GetLicenseExpiryDate(expiry_date)
  # @param [FFI::Pointer(*Uint32T)] expiry_date
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseExpiryDate, :GetLicenseExpiryDate, [:pointer], :int

  # @method GetLicenseUserEmail(email, length)
  # @param [String] email
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseUserEmail, :GetLicenseUserEmail, [:string, :uint], :int

  # @method GetLicenseUserName(name, length)
  # @param [String] name
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseUserName, :GetLicenseUserName, [:string, :uint], :int

  # @method GetLicenseType(license_type, length)
  # @param [String] license_type
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetLicenseType, :GetLicenseType, [:string, :uint], :int

  # @method GetActivationMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetActivationMetadata, :GetActivationMetadata, [:string, :string, :uint], :int

  # @method GetTrialActivationMetadata(key, value, length)
  # @param [String] key
  # @param [String] value
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetTrialActivationMetadata, :GetTrialActivationMetadata, [:string, :string, :uint], :int

  # @method GetTrialExpiryDate(trial_expiry_date)
  # @param [FFI::Pointer(*Uint32T)] trial_expiry_date
  # @return [Integer]
  # @scope class
  attach_function :GetTrialExpiryDate, :GetTrialExpiryDate, [:pointer], :int

  # @method GetTrialId(trial_id, length)
  # @param [String] trial_id
  # @param [Integer] length
  # @return [Integer]
  # @scope class
  attach_function :GetTrialId, :GetTrialId, [:string, :uint], :int

  # @method GetLocalTrialExpiryDate(trial_expiry_date)
  # @param [FFI::Pointer(*Uint32T)] trial_expiry_date
  # @return [Integer]
  # @scope class
  attach_function :GetLocalTrialExpiryDate, :GetLocalTrialExpiryDate, [:pointer], :int

  # @method ActivateLicense()
  # @return [Integer]
  # @scope class
  attach_function :ActivateLicense, :ActivateLicense, [], :int

  # @method ActivateLicenseOffline(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :ActivateLicenseOffline, :ActivateLicenseOffline, [:string], :int

  # @method GenerateOfflineActivationRequest(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :GenerateOfflineActivationRequest, :GenerateOfflineActivationRequest, [:string], :int

  # @method DeactivateLicense()
  # @return [Integer]
  # @scope class
  attach_function :DeactivateLicense, :DeactivateLicense, [], :int

  # @method GenerateOfflineDeactivationRequest(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :GenerateOfflineDeactivationRequest, :GenerateOfflineDeactivationRequest, [:string], :int

  # @method IsLicenseGenuine()
  # @return [Integer]
  # @scope class
  attach_function :IsLicenseGenuine, :IsLicenseGenuine, [], :int

  # @method IsLicenseValid()
  # @return [Integer]
  # @scope class
  attach_function :IsLicenseValid, :IsLicenseValid, [], :int

  # @method ActivateTrial()
  # @return [Integer]
  # @scope class
  attach_function :ActivateTrial, :ActivateTrial, [], :int

  # @method ActivateTrialOffline(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :ActivateTrialOffline, :ActivateTrialOffline, [:string], :int

  # @method GenerateOfflineTrialActivationRequest(file_path)
  # @param [String] file_path
  # @return [Integer]
  # @scope class
  attach_function :GenerateOfflineTrialActivationRequest, :GenerateOfflineTrialActivationRequest, [:string], :int

  # @method IsTrialGenuine()
  # @return [Integer]
  # @scope class
  attach_function :IsTrialGenuine, :IsTrialGenuine, [], :int

  # @method ActivateLocalTrial(trial_length)
  # @param [Integer] trial_length
  # @return [Integer]
  # @scope class
  attach_function :ActivateLocalTrial, :ActivateLocalTrial, [:uint], :int

  # @method IsLocalTrialGenuine()
  # @return [Integer]
  # @scope class
  attach_function :IsLocalTrialGenuine, :IsLocalTrialGenuine, [], :int

  # @method ExtendLocalTrial(trial_extension_length)
  # @param [Integer] trial_extension_length
  # @return [Integer]
  # @scope class
  attach_function :ExtendLocalTrial, :ExtendLocalTrial, [:uint], :int

  # @method Reset()
  # @return [Integer]
  # @scope class
  attach_function :Reset, :Reset, [], :int
end
