platform :ios, '15.0'

def shared_pods
  
  pod 'Alamofire'
  pod 'RxSwift'
  pod 'Swinject'
end

target 'VideoMerger-Apple' do
  use_frameworks!
  
  shared_pods
  pod 'ProgressHUD'
  pod 'SnapKit'
  pod 'SwiftyJSON'
end

target 'VideoMerger-Apple-Tests' do
  use_frameworks!
  
  shared_pods
  pod 'Nimble'
  pod 'Quick'
end
