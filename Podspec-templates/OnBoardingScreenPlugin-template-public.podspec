Pod::Spec.new do |s|
  s.name  = "__framework_name__"
  s.version = '__version__'
  s.platform  = :ios, '__ios_platform_version__'
  s.summary = "__framework_name__"
  s.description = "__framework_name__ container."
  s.homepage  = "https://github.com/applicaster-plugins/__framework_name__-iOS"
  s.license = 'CMPS'
  s.author = { "cmps" => "Applicaster LTD." }
  s.source = {
      "http" => "__source_url__"
  }

  s.requires_arc = true
  s.static_framework = true

  s.public_header_files = '__framework_name__/**/*.h'
  s.source_files = '__framework_name__/**/*.{h,m,swift}'

  s.vendored_frameworks = '__framework_name__.framework'

  s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                'ENABLE_BITCODE' => 'YES',
                'SWIFT_VERSION' => '__swift_version__',
                'OTHER_CFLAGS'  => '-fembed-bitcode'
              }

  s.dependency 'ApplicasterSDK'
  s.dependency 'ZappPlugins'
  s.dependency 'MBProgressHUD'
  s.dependency 'SwiftyJSON', '~> 4.2.0'
  s.dependency 'Alamofire', '~> 4.8.0'
  s.dependency 'RxSwift', '~> 4.4.1'
  s.dependency 'RxCocoa', '~> 4.4.1'
  s.dependency 'SDWebImage', '~> 4.4.6'
end
