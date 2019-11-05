#
# Be sure to run `pod lib lint ACPolygonView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ACPolygonView'
  s.version          = '0.2.0'
  s.summary          = 'Draw and modify polygons inside a view.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ACPolygonView is a tool useful for drawing and manipulating polygons inside a UIView.
                       DESC

  s.homepage         = 'https://github.com/rhcpfan/ACPolygonView'
  s.screenshots     = 'https://user-images.githubusercontent.com/3796970/68125913-54000c80-ff1b-11e9-89ab-4564619fb701.png', 'https://user-images.githubusercontent.com/3796970/68125875-3cc11f00-ff1b-11e9-81f0-6339f0c194a2.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrei Ciobanu' => 'ac.ciobanu@yahoo.com' }
  s.source           = { :git => 'https://github.com/rhcpfan/ACPolygonView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/rhcpfan91'

  s.ios.deployment_target = '8.0'
  s.source_files = 'ACPolygonView/Classes/**/*'

  s.frameworks = 'UIKit', 'QuartzCore'
  s.swift_version = '5.0'
end
