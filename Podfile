platform :ios, '13.0'
inhibit_all_warnings!
use_frameworks!

target 'Tic Tac' do
    pod 'FLEX'
    pod 'TBAlertController', :path => '../TBAlertController', :branch => 'master'
    pod 'MCSwipeTableViewCell'
    pod 'Masonry'
    pod 'YakKit', :path => '../YakKit'
    # pod 'YakKit', :git => 'https://github.com/ThePantsThief/YakKit.git'
    pod 'Objc-iOS-Extensions', :path => '../Objc-iOS-Extensions'
    pod 'Objc-Foundation-Extensions', :path => '../Objc-Foundation-Extensions'
    pod 'libextobjc'
    pod 'AutoCoding'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['SWIFT_VERSION'] = '5.3'
    end
  end
end
