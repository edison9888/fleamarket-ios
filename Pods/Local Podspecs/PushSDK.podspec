
Pod::Spec.new do |s|
  s.name         = "PushSDK"
  s.version      = "1.0.0"
  s.summary      = "PushSDK"

  s.source_files = '**/*.h'
  s.preserve_paths = 'PushCenterSDK.framework','TBSDKNetworkSDK.framework'
  s.requires_arc = true
  s.frameworks = 'PushCenterSDK','TBSDKNetworkSDK'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(SRCROOT)/libs/Frameworks/PushSDK"' } 

end
