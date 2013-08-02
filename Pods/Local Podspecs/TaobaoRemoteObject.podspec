Pod::Spec.new do |s|
  s.name         = "TaobaoRemoteObject"
  s.version      = "2.0"
  s.summary      = "A short description of TaobaoRemoteObject."
  
  s.homepage     = "http://gitlab.alibaba-inc.com/tbremoteobject"

  s.license      = 'MIT'

  s.author       = { "wentong" => "wentong@taobao.com" }

  s.source       = { :git => "http://gitlab.alibaba-inc.com/tbremoteobject.git", :tag => "v1.9" }


  s.platform     = :ios, '5.0'

  s.ios.deployment_target = '5.0'

  s.source_files = 'TaobaoRemoteObject/**/*.{h,m}'


  s.public_header_files = 'TaobaoRemoteObject/**/*.h'

  
  s.requires_arc = true

  s.dependency 'AFNetworking', '~>1.3.0'
  s.dependency 'libextobjc', '0.2.5'
  s.dependency 'iOS_Util/Json', '0.10.0'
  s.dependency 'iOS_Util/Common', '0.10.0'
  s.frameworks = 'Security' , 'MobileCoreServices' ,'SystemConfiguration' 

    s.prefix_header_contents = <<-EOS
  
#ifdef DEBUG
#define TBRO_DEBUG
#endif

EOS

end
