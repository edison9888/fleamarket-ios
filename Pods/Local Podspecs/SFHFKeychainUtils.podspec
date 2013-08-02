
Pod::Spec.new do |s|
  s.name         = "SFHFKeychainUtils"
  s.version      = "1.0.0"
  s.summary      = "SFHFKeychainUtils"

  s.source_files = '*.{h,m}'
  s.public_header_files = "*.h"
  s.requires_arc = false

  s.framework = 'Security'

end
