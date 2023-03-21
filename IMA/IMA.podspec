Pod::Spec.new do |s|
    s.name = 'IMA'
    s.version = '4.8.2'
    s.authors = ''
    s.homepage = 'https://developers.google.com/interactive-media-ads/docs/sdks/tvos/'
    s.summary = 'IMA'
    s.source = { :local => '.' }
    s.platform = :tvos
    s.vendored_frameworks = 'GoogleInteractiveMediaAds.xcframework'
end