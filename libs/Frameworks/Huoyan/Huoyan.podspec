
Pod::Spec.new do |s|
  s.name         = "Huoyan"
  s.version      = "1.0.0"
  s.summary      = "Huoyan"

  s.source_files = '**/*.h'
  s.preserve_paths = 'huoyan.framework','TBScanLib.framework'
  s.requires_arc = true
  s.frameworks = 'huoyan','TBScanLib'
  s.resource = "huoyan.bundle"
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(SRCROOT)/libs/Frameworks/Huoyan"' } 

end
