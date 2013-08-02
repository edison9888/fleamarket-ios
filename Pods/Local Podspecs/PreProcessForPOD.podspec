Pod::Spec.new do |s|
  s.name     = 'PreProcessForPOD'
  s.version  = '1.0.0'
  s.license  = 'MIT'

  
  s.requires_arc = true
 
  s.prefix_header_contents = <<-EOS
  
#ifdef DEBUG
#define TBRO_DEBUG
#define TBMB_DEBUG
#endif

EOS
end