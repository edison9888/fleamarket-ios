Pod::Spec.new do |s|
  s.name         = "Lame"
  s.version      = "1.0.0"
  s.summary      = "Lame"

  s.source_files = '*.{h,m}'
  s.public_header_files = "*.h"
  s.preserve_paths = 'libmp3lame.a'
  s.library   = 'mp3lame'
  s.xcconfig  =  { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/libs/Sources/Lame"' }

end
