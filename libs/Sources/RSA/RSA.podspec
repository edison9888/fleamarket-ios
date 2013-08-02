
Pod::Spec.new do |s|
  s.name         = "RSA"
  s.version      = "1.0.0"
  s.summary      = "RSA"

  s.source_files = '*.{h,mm}'
  s.public_header_files = "*.h"
  s.requires_arc = true

end
