Pod::Spec.new do |s|
  s.name         = "hybid-ios-sdk"
  s.module_name  = 'HyBidSDK'
  s.version      = "2.6.1"
  s.summary      = "This is the iOS SDK of HyBid. You can read more about it at https://pubnative.net."
  s.description = <<-DESC
                     HyBid leverages first-look prebid technology to maximize yield for the publishers across
                     their current monetization suit. Access to the unique demand across different formats allows
                     publishers to immediately benefit with additional revenues on top of their current yield. Prebid technology
                     allows getting a competitive bid before executing your regular waterfall logic, and then
                     participate in the relevant auctions in the cascade.
                   DESC
  s.homepage     = "https://github.com/gzach/pubnative-hybid-ios-sdk-1"
  s.documentation_url = "https://developers.pubnative.net/v3.0/docs/hybid"
  s.license             = { :type => "MIT", :text => <<-LICENSE
    MIT License
    Copyright (c) 2021 PubNative GmbH
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
      LICENSE
    }

  s.authors      = { "Can Soykarafakili" => "can.soykarafakili@pubnative.net", "Eros Garcia Ponte" => "eros.ponte@pubnative.net", "Fares Benhamouda" => "fares.benhamouda@pubnative.net", "Orkhan Alizada" => "orkhan.alizada@pubnative.net"  }
  s.platform     = :ios

  s.ios.deployment_target = "10.0"
  s.swift_version    = '5.0'
  s.source       = { :git => "https://github.com/gzach/pubnative-hybid-ios-sdk-1.git", :tag => "2.6.1" }

  s.frameworks       = [
                            'AVFoundation',
                            'AVKit',
                            'CoreGraphics',
                            'CoreLocation',
                            'CoreMedia',
                            'CoreTelephony',
                            'Foundation',
                            'MediaPlayer',
                            'QuartzCore',
                            'SystemConfiguration',
                            'UIKit',
                            'SafariServices'
                          ]
  s.weak_frameworks  = [
                            'AdSupport',
                            'StoreKit',
                            'WebKit'
                          ]
  s.default_subspecs = 'HyBidSDK'
  
  s.xcconfig = {
    'OTHER_LDFLAGS' => '-framework OMSDK-Static_Pubnativenet'
  }
  
  s.subspec 'HyBidSDK' do |sdk|
    sdk.dependency              'hybid-ios-sdk/Core'
    sdk.dependency              'hybid-ios-sdk/Native'
    sdk.dependency              'hybid-ios-sdk/Banner'
    sdk.dependency              'hybid-ios-sdk/FullScreen'
    sdk.dependency              'hybid-ios-sdk/RewardedVideo'
  end
  
  s.subspec 'Core' do |core|
    core.source_files          = 'PubnativeLite/PubnativeLite/Core/**/*.{swift,h,m}'
    core.resources            =  ['PubnativeLite/PubnativeLite/Resources/**/*', 'PubnativeLite/PubnativeLite/OMSDK-1.3.22/*.js', 'PubnativeLite/PubnativeLite/Core/MRAID/*.js']
    core.exclude_files         = 'PubnativeLite/PubnativeLite/Core/HyBidStatic.{swift,h,m}'
    core.vendored_frameworks   = ['PubnativeLite/PubnativeLite/OMSDK-1.3.22/*.{xcframework}']
  end

  s.subspec 'Banner' do |banner|
    banner.dependency           'hybid-ios-sdk/Core'
    banner.source_files         = ['PubnativeLite/PubnativeLite/Banner/**/*.{swift,h,m}']
  end

  s.subspec 'Native' do |native|
    native.dependency           'hybid-ios-sdk/Core'
        native.source_files     = ['PubnativeLite/PubnativeLite/Native/**/*.{swift,h,m}']
  end

  s.subspec 'FullScreen' do |fullscreen|
    fullscreen.dependency       'hybid-ios-sdk/Core'
    fullscreen.source_files     = ['PubnativeLite/PubnativeLite/FullScreen/**/*.{swift,h,m}']
  end

  s.subspec 'RewardedVideo' do |rewarded|
    rewarded.dependency         'hybid-ios-sdk/Core'
    rewarded.source_files       = ['PubnativeLite/PubnativeLite/Rewarded/**/*.{swift,h,m}']
  end

end
