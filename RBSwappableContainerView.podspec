Pod::Spec.new do |s|
  s.name          = "RBSwappableContainerView"
  s.version       = "1.0.0"
  s.summary       = "An UIViewController to allow for swapping out the ViewControllers in a UIContainerView, with animations."
  s.homepage      = "https://github.com/eoghain/RBSwappableContainerView"
  s.license       = "MIT"
  s.screenshots   = "https://raw.githubusercontent.com/eoghain/RBSwappableContainerView/master/Screenshots/TransitionAnimation.png"
  s.author        = { "eoghain" => "rob.o.booth@gmail.com" }
  s.platform      = :ios, '7.0'
  s.source        = { :git => "https://github.com/eoghain/RBSwappableContainerView.git", :tag => s.version }
  s.source_files  = "Classes", "Classes/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.requires_arc  = true
end
