#
# Be sure to run `pod lib lint SSegmentRecordingView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SSegmentRecordingView'
  s.version          = '0.1.0'
  s.summary          = 'View to represent segments of video as Snapchat, Instagram or TikTok camera.'
  s.homepage         = 'https://github.com/asam139/SSegmentRecordingView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'asam139' => '93sauu@gmail.com' }
  s.source           = { :git => 'https://github.com/asam139/SSegmentRecordingView.git', :tag => s.version.to_s }
  s.swift_version = '4.2'
  s.ios.deployment_target = '11.3'

  s.source_files = 'SSegmentRecordingView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SSegmentRecordingView' => ['SSegmentRecordingView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
