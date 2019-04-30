platform :ios, '10.0'
use_frameworks!
install! 'cocoapods', :deterministic_uuids => false

source 'git@github.com:applicaster/CocoaPods.git'
source 'git@github.com:applicaster/CocoaPods-Private.git'
source 'git@github.com:applicaster/PluginsBuilderCocoaPods.git'
source 'git@github.com:CocoaPods/Specs.git'


def shared
  pod 'ApplicasterSDK'
  pod 'ZappPlugins'
  pod 'MBProgressHUD'
  pod 'SwiftyJSON', '~> 4.2.0'
  pod 'Alamofire', '~> 4.8.0'
  pod 'RxSwift', '~> 4.4.1'
  pod 'RxCocoa', '~> 4.4.1'
  pod 'SDWebImage', '~> 4.4.6'
end

target 'OnBoardingScreenPluginDEMO' do
    pod 'OnBoardingScreenPlugin', :path => 'OnBoardingScreenPlugin.podspec'
    shared
end

target 'OnBoardingScreenPlugin' do
  shared
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end