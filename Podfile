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
  pod 'SwiftyJSON'
  pod 'Alamofire'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SDWebImage'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
