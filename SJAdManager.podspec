

Pod::Spec.new do |s|


  s.name         = "SJAdManager"
  s.version      = "1.0.0"
  s.summary      = ""
  s.description  = <<-DESC
                   A longer description of SJAdManager in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/chensj1901/SJAdManager"
  s.license      = "MIT (example)"
  s.author             = { "chensj1901" => "email@address.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/chensj1901/SJAdManager.git", :tag => "1.0.0" }
  s.source_files  = "SJAdManagerLib/*.{h,m}"

  s.frameworks = "AddressBook","Foundation","UIKit","CoreGraphics","QuartzCore","SystemConfiguration","CoreTelephony","CoreLocation","AudioToolbox","MessageUI","MapKit","MediaPlayer","AVFoundation","CoreMotion","CoreAudio","CoreMedia","MobileCoreServices","CFNetwork","Security","ImageIO","EventKit","EventKitUI","CoreData","StoreKit","Social","Accelerate","CoreText","iAd","CoreImage","AssetsLibrary","CoreFoundation"
  s.weak_frameworks = "AdSupport","GameController"
  s.libraries = "iconv", "sqlite3","sqlite3.0","z","z.1.2.5","stdc++","xml2"
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.ios.vendored_libraries =  "lib/*.a"
  s.requires_arc = true
  s.dependency 'SFHFKeychainUtils', '~> 0.0.1'
end
