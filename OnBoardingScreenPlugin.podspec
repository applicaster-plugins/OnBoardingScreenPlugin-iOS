Pod::Spec.new do |s|
    s.name             = "OnBoardingScreenPlugin"
    s.version          = '1.0.23'
    s.summary          = "On-boarding plugin that allows user to select preferences in content so that feeds and push notifications are customized for specific user for Zapp iOS."
    s.description      = <<-DESC
    On-boarding plugin that allows user to select preferences in content so that feeds and push notifications are customized for specific user for Zapp iOS.
                         DESC
    s.homepage         = "https://github.com/applicaster-plugins/OnBoardingScreenPlugin-iOS"
    s.license          = 'MIT'
    s.author           = { "Marcos Reyes - Applicaster" => "m.reyes@applicaster.com" }
    s.source           = { :git => "git@github.com:applicaster-plugins/OnBoardingScreenPlugin-iOS", :tag => s.version.to_s }

    s.platform     = :ios, '10.0'
    s.requires_arc = true
    s.resources = ["OnBoardingScreenPlugin/*.{xib,storyboard,png,ttf,jpg}"]
    s.public_header_files = 'OnBoardingScreenPlugin/*.h'
    s.source_files = 'OnBoardingScreenPlugin/*.{swift,h,m}'

    s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                    'ENABLE_BITCODE' => 'YES',
                    'OTHER_LDFLAGS' => '$(inherited)',
                    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}"/**',
                    'LIBRARY_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}"/**',
                    'SWIFT_VERSION' => '4.2'
                  }

    s.dependency 'ApplicasterSDK'
    s.dependency 'ZappPlugins'
    s.dependency 'MBProgressHUD'
    s.dependency 'SwiftyJSON'
    s.dependency 'Alamofire'
    s.dependency 'RxSwift'
    s.dependency 'RxCocoa'
    s.dependency 'SDWebImage'

  end
