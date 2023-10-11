platform :ios, '15.0'

def shared_pods
  
  pod 'Alamofire'
  pod 'RxSwift'
  pod 'SwiftyJSON'
  pod 'Swinject'
end

def test_pods
  shared_pods
  pod 'Nimble'
  pod 'Quick'
end

target 'VideoMerger-Apple' do
  use_frameworks!
  
  shared_pods
  pod 'ProgressHUD'
  pod 'RxCocoa'
  pod 'SnapKit'
end

target 'FiltersModelTests' do
  use_frameworks!
  
  test_pods
end

target 'FiltersViewModelTests' do
  use_frameworks!
  
  test_pods
end
