
Pod::Spec.new do |s|
  s.name         = "WebP"
  s.version      = "1.0.1"
  s.summary      = "WebP"

  s.source_files = '**/*.h'
  s.preserve_paths = 'WebP.framework'
  s.requires_arc = true
  s.frameworks = 'WebP'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(SRCROOT)/libs/Frameworks/WebP"' } 

end
