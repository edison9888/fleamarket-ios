Pod::Spec.new do |s|
  s.name         = "TBSocialShareSDK"
  s.version      = "0.1"
  s.summary      = "A short description of TBSocialShareSDK."
  
  s.homepage     = "git@gitlab.alibaba-inc.com:tbw/tbsocialsharesdk.git"

  s.license      = 'MIT'

  s.author       = { "yuanxiao" => "yuanxiao@taobao.com" }

  s.source       = { :git => "git@gitlab.alibaba-inc.com:tbw/tbsocialsharesdk.git" }


  s.platform     = :ios, '5.0'

  s.ios.deployment_target = '5.0'

  s.subspec 'shareClass' do |tbs|
    tbs.source_files = 'TBSocialShareSDK/TBSocialShare/TBSocialShareClass/**/*.{h,m}'
    tbs.public_header_files = 'TBSocialShareSDK/TBSocialShare/TBSocialShareClass/**/*.h'
    tbs.requires_arc = true
  end

  s.subspec 'sinas' do |ss|
    ss.source_files = 'TBSocialShareSDK/TBSocialShare/ThirdPartySDK/SinaWeibo/*.{h,m}'
    ss.public_header_files = 'TBSocialShareSDK/TBSocialShare/ThirdPartySDK/SinaWeibo/*.h'
    ss.dependency 'SFHFKeychainUtils'
    ss.requires_arc = false
  end

  s.subspec 'weixin' do |ws|
    ws.source_files = 'TBSocialShareSDK/TBSocialShare/ThirdPartySDK/WeiChat/*.{h,m,mm}'
    ws.public_header_files = 'TBSocialShareSDK/TBSocialShare/ThirdPartySDK/WeiChat/*.h'
    ws.preserve_paths = "TBSocialShareSDK/TBSocialShare/ThirdPartySDK/WeiChat/**"
    ws.library   = 'WeChatSDK_armv7_armv7s'
    ws.xcconfig  = { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/TBSocialShareSDK/TBSocialShareSDK/TBSocialShare/ThirdPartySDK/WeiChat"' }
  end

  s.subspec 'douban' do |dbs|
    dbs.source_files = 'TBSocialShareSDK/TBSocialShare/ThirdPartySDK/GTDouban/**/*.{h,m}'
    dbs.public_header_files = 'TBSocialShareSDK/TBSocialShare/ThirdPartySDK/GTDouban/**/*.h'
    dbs.dependency 'SFHFKeychainUtils'
    dbs.requires_arc = false
  end
end








