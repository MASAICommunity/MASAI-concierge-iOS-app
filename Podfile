platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!



def common_pods
  pod 'SwiftyJSON'
  pod 'Pantry'
  pod 'Auth0'
  pod 'SimpleKeychain'
  pod 'Alamofire', '~> 4.5'
end


target 'masai' do
  common_pods

  pod 'Starscream'
  pod 'AnimatedTextInput'
  pod 'Typist'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SlackTextViewController', :git => 'https://github.com/slackhq/SlackTextViewController.git', :commit => '46113e08e411ff174793073e3d292c50b9d1964d' # fixes iOS 11 non-interactivity issues
  pod 'AlamofireNetworkActivityIndicator', '~> 2.2'
  pod 'RealmSwift'
  pod 'Cosmos', '~> 8.0'
  pod 'ImageSlideshow'
  pod 'IQKeyboardManagerSwift', '~> 5.0'
  pod 'PhoneNumberKit', '~> 1.3'
  pod "PromiseKit", "~> 4.4"
  pod 'Kingfisher', '~> 3.13'
  pod 'SwiftDate', '~> 4.3.0'

end


target 'MasaiTests' do
  common_pods
end
