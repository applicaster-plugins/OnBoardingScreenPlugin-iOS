platform :ios, '10.0'

source 'git@github.com:applicaster/CocoaPods.git'
source 'git@github.com:applicaster/CocoaPods-Private.git'
source 'git@github.com:applicaster/PluginsBuilderCocoaPods.git'
source 'git@github.com:CocoaPods/Specs.git'

target 'OnBoardingScreenPlugin' do
  use_frameworks!
  
  pod 'ApplicasterSDK'
  pod 'ZappPlugins'
  pod 'MBProgressHUD'
  pod 'SwiftyJSON', '~> 4.2.0'
  pod 'Alamofire', '~> 4.8.0'
  pod 'RxSwift', '~> 4.4.1'
  pod 'RxCocoa', '~> 4.4.1'
  pod 'SDWebImage', '~> 4.4.6'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
