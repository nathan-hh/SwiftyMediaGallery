#
# Be sure to run `pod lib lint SwiftyMediaGallery.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'SwiftyMediaGallery'
    s.version          = '0.1.1'
    s.summary          = 'SwiftyMediaGallery let you easy swipe media -  native apple style.'
    s.requires_arc = true

    s.description      = <<-DESC
    SwiftyMediaGallery is a very convenient and easy library to display images and videos in your iOS app
                       DESC

    s.homepage         = 'https://github.com/nathan-hh/SwiftyMediaGallery'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'nathan-hh' => 'nathan' }
    s.source           = { :git => 'https://github.com/nathan-hh/SwiftyMediaGallery.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '13.0'

    s.swift_version = "5.0"
    s.source_files = 'Sources/**/*.{h,m,swift}'

  # s.resource_bundles = {
  #    'SwiftyMediaGallery' => ['Sources/Assets/*.png']
  # }

    s.resources = 'Sources/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}'

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit','Combine' ,'AVFoundation', 'SwiftUI'
    s.dependency 'CombineDataSources'
end
