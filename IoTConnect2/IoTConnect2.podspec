#
#  Be sure to run `pod spec lint IoTConnect2.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "IoTConnect2"
  spec.version      = "1.0"
  spec.summary      = "Version 2 for ioTConnectSDk"


  spec.description  = "This SDK is used to connect portal"

  spec.homepage     = "https://github.com/sw-tt-kirtanvaghela/TestPod2.git"
 
  spec.license      = "MIT"

  spec.author             = { "sw-tt-kirtanvaghela" => "135005218+sw-tt-kirtanvaghela@users.noreply.github.com" }

   # spec.platform     = :ios
   spec.platform     = :ios, "12.0"


  spec.source       = { :git => "https://github.com/sw-tt-kirtanvaghela/TestPod2.git", :tag  => "1.0"}

   spec.source_files  = "IoTConnect2/**/*"
   spec.swift_version = "5.0"
   spec.dependency "CocoaMQTT"

end
