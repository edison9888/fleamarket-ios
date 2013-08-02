
Pod::Spec.new do |s|
  s.name         = "TBSDK"
  s.version      = "1.0.0"
  s.summary      = "TBSDK"

  s.source_files = '**/*.h'
  s.preserve_paths = 'LoginSDK.framework','SSOLoginSDK.framework','PushCenterSDK.framework','TBSDKNetworkSDK.framework','TBSecuritySDK.framework'
  s.requires_arc = true
  s.frameworks = 'LoginSDK','SSOLoginSDK','PushCenterSDK','TBSDKNetworkSDK','TBSecuritySDK'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(SRCROOT)/libs/Frameworks/TBSDK"' } 

  s.dependency 'ASIHTTPRequest','~>1.8.1'
  s.dependency 'JSONKit' ,'1.4'
  s.dependency 'Reachability' ,'~>3.1.0'

end
