SWIFT_VERSION = '4.0'

platform :tvos, '10.0'

# Decide which CocoaPods public spec repo to use
COCOAPODS_VERSION_MAJOR=%x( pod --version | cut -d'.' -f1 ).to_i unless defined? COCOAPODS_VERSION_MAJOR
COCOAPODS_VERSION_MINOR=%x( pod --version | cut -d'.' -f2 ).to_i unless defined? COCOAPODS_VERSION_MINOR
if((COCOAPODS_VERSION_MAJOR >= 1 && COCOAPODS_VERSION_MINOR >= 8) || COCOAPODS_VERSION_MAJOR >= 2)
  # As of CocoaPods 1.8.0, the CDN link is the default public spec repo
  source 'https://cdn.cocoapods.org'
else
  source 'https://github.com/CocoaPods/Specs.git'
end

source 'https://github.com/socialvibe/cocoapod-specs.git'
source 'https://github.com/Innovid/cocoapods-spec.git'
source 'https://github.com/YOU-i-Labs/YouiTVAdRenderer-CocoaPod.git'

target 'TruexGoogleReferenceApp' do
    use_frameworks!
    pod 'TruexAdRenderer', '3.8.2'
    pod 'IMA', :path => './IMA'
end

post_install do |installer|
    print "Setting the default SWIFT_VERSION to #{SWIFT_VERSION}\n"
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = "#{SWIFT_VERSION}"
    end

    installer.pods_project.targets.each do |target|
        if ['TruexGoogleReferenceApp'].include? "#{target}"
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
