# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'Menual' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Menual

  inhibit_all_warnings!
  pod 'RIBs', :git=> 'https://github.com/uber/RIBs', :tag => '0.9.2'
  pod 'RxRelay'
  pod 'SnapKit', '~> 5.0.0'
  
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxRealm'
  pod 'Realm', '10.20.1'
  pod 'RealmSwift', '10.20.1'

  # Google
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  
  # then 문법 사용
  pod 'Then'
  

  target 'MenualTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MenualUITests' do
    # Pods for testing
    pod 'RIBs', :git=> 'https://github.com/uber/RIBs', :tag => '0.9.2'
  end
  
  # 설치시에 13.0으로 타겟 변경
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end

end
