
Pod::Spec.new do |s|
  s.name         = "iOS_Util"
  s.version      = "0.10.0"
  s.summary      = "Some iOS Util"
  s.homepage     = "http://gitlab.alibaba-inc.com/tbw/ios_util"

  s.license      = 'MIT'

  s.author       = { "文通" => "wentong@taobao.com" }
  s.source       = { :git => "git@gitlab.alibaba-inc.com:tbw/ios_util.git", :tag => "0.10.0" }


  s.platform     = :ios, '6.1'

  s.ios.deployment_target = '4.3'

  s.subspec 'Common' do |cos|
    cos.source_files = 'iOS_Util/Common/*.{h,m}'
    cos.public_header_files = 'iOS_Util/Common/*.h'
  end

  s.subspec 'Core' do |cs|
    cs.source_files = 'iOS_Util/Core/*.{h,m}'
    cs.public_header_files = 'iOS_Util/Core/*.h'
    cs.dependency 'libextobjc', '0.2.5'
  end

  s.subspec 'Json' do |js|
    js.source_files = 'iOS_Util/Json/*.{h,m}'
    js.public_header_files = 'iOS_Util/Json/*.h'
    js.dependency 'iOS_Util/Core'
  end

  s.subspec 'Bean' do |bs|
    bs.source_files = 'iOS_Util/Bean/*.{h,m}'
    bs.public_header_files = 'iOS_Util/Bean/*.h'
    bs.dependency 'iOS_Util/Core'
  end

  s.subspec 'DB' do |ds|
    ds.source_files = 'iOS_Util/DB/*.{h,m}'
    ds.public_header_files = 'iOS_Util/DB/*.h'
    ds.dependency 'FMDB/standard' ,'~> 2.1'
    ds.dependency 'iOS_Util/Common'
    ds.dependency 'iOS_Util/Core'
  end

  s.subspec 'WebP' do |ws|
    ws.source_files = 'iOS_Util/WebP/*.{h,m}'
    ws.public_header_files = 'iOS_Util/WebP/*.h'
    ws.dependency 'libwebp' ,'~> 0.3.0-rc7'
    ws.frameworks = 'CoreGraphics'
  end

  s.subspec 'Location' do |ls|
    ls.source_files = 'iOS_Util/Location/*.{h,m}'
    ls.public_header_files = 'iOS_Util/Location/*.h'
    ls.dependency 'iOS_Util/Common'
    ls.dependency 'iOS_Util/DB'
    ls.frameworks = 'CoreLocation' ,'MapKit'
    ls.resource = 'iOS_Util/Location/chinaDivision.sqlite'
  end

  s.subspec 'AMR' do |as|
    as.source_files = 'iOS_Util/AMR/**/*.{h,m,mm}'
    as.public_header_files = 'iOS_Util/AMR/**/*.h'
    as.preserve_paths = "iOS_Util/AMR/**"
    as.library   = 'opencore-amrnb','opencore-amrwb'
    as.xcconfig  = { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/iOS_Util/iOS_Util/AMR/lib"' }
  end

  s.subspec 'Cache' do |cas|
    cas.source_files = 'iOS_Util/Cache/*.{h,m,mm}'
    cas.public_header_files = 'iOS_Util/Cache/*.h'
    cas.dependency 'iOS_Util/Common'
  end

  s.subspec 'Preference' do |ps|
    ps.source_files = 'iOS_Util/Preference/*.{h,m,mm}'
    ps.public_header_files = 'iOS_Util/Preference/*.h'
    ps.dependency 'iOS_Util/Json'
  end

  s.requires_arc = true


  
end
