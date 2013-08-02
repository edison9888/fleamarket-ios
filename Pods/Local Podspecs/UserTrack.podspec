
Pod::Spec.new do |s|
  s.name         = "UserTrack"
  s.version      = "2.0.0"
  s.summary      = "UserTrack"

  s.source_files = '**/*.h'
  s.preserve_paths = 'UT.framework'
  s.requires_arc = true
  s.frameworks = 'UT' , 'CoreTelephony' ,'Security' ,'SystemConfiguration'
  s.weak_frameworks = 'AdSupport' 
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(SRCROOT)/libs/Frameworks/UserTrack"' } 

end
