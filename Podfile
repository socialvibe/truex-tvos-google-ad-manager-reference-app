platform :tvos, '10.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/socialvibe/cocoapod-specs.git'
source 'https://innovid-cocoapods:3bbe7445d58951a8f89c5e54c0ebfdd17039589e@github.com/Innovid/cocoapods-spec.git'
source 'https://github.com/YOU-i-Labs/YouiTVAdRenderer-CocoaPod.git'

target 'DFP Integration Demo' do
    use_frameworks!

    pod 'TruexAdRenderer', '~> 3.3.0-rc.2'
    pod 'IMA', :path => './IMA'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.3'
        end
    end
end
