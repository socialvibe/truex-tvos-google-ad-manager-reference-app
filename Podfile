XCODE_VERSION_MAJOR=%x( xcodebuild -version |  grep -i -E "^xcode [\-beta\ ]*[0-9]+\.[0-9]+" | head -1 | sed "s/[^0-9\.]//g" | cut -d'.' -f1 | tr -d '\n' )
XCODE_VERSION_MINOR=%x( xcodebuild -version |  grep -i -E "^xcode [\-beta\ ]*[0-9]+\.[0-9]+" | head -1 | sed "s/[^0-9\.]//g" | cut -d'.' -f2 | tr -d '\n' )
XCODE_VERSION = "xcode#{XCODE_VERSION_MAJOR}_#{XCODE_VERSION_MINOR}"
print("Found XCODE_VERSION: #{XCODE_VERSION}\n")
if(XCODE_VERSION != 'xcode10_1' and XCODE_VERSION != 'xcode10_2' and XCODE_VERSION != 'xcode11_0')
  print('Unable to determine Xcode version. Defaulting to Xcode 11.0\n')
  XCODE_VERSION = 'xcode11_0'
end
XCODE_VERSION_OVERRIDE = %x( echo $TX_XCODE ).to_s.strip
unless XCODE_VERSION_OVERRIDE.empty?
  print("Overriding Xcode version to #{XCODE_VERSION_OVERRIDE}\n")
  XCODE_VERSION = XCODE_VERSION_OVERRIDE
end

SWIFT_VERSION = '5.1'
if XCODE_VERSION == 'xcode10_1'
    SWIFT_VERSION = '3.3'
elsif XCODE_VERSION == 'xcode10_2'
    SWIFT_VERSION = '4.0'
end

platform :tvos, '13.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/socialvibe/cocoapod-specs.git'
source 'https://github.com/Innovid/cocoapods-spec.git'

target 'TruexGoogleReferenceApp' do
    use_frameworks!
    pod 'TruexAdRenderer', '~> 3.7'
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
