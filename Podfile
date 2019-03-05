SWIFT_VERSION = '3.2'

platform :tvos, '10.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/socialvibe/cocoapod-specs.git'
source 'https://innovid-cocoapods:3bbe7445d58951a8f89c5e54c0ebfdd17039589e@github.com/Innovid/cocoapods-spec.git'
source 'https://github.com/YOU-i-Labs/YouiTVAdRenderer-CocoaPod.git'

target 'DFP Integration Demo' do
    use_frameworks!
    pod 'TruexAdRenderer', '~> 3.6'
    pod 'IMA', :path => './IMA'
end

post_install do |installer|
    print "Setting the default SWIFT_VERSION to #{SWIFT_VERSION}\n"
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = "#{SWIFT_VERSION}"
    end

    installer.pods_project.targets.each do |target|
        if ['DFP Integration Demo'].include? "#{target}"
            print "Setting #{target}'s SWIFT_VERSION to #{SWIFT_VERSION}\n"
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = "#{SWIFT_VERSION}"
            end
        else
            print "Setting #{target}'s SWIFT_VERSION to Undefined (Xcode will automatically resolve)\n"
            target.build_configurations.each do |config|
                config.build_settings.delete('SWIFT_VERSION')
            end
        end
    end
end
