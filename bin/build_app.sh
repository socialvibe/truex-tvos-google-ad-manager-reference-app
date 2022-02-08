xcodebuild -workspace "TruexGoogleReferenceApp.xcworkspace" \
           -scheme "TruexGoogleReferenceApp" \
           -configuration release \
           -sdk appletvsimulator \
           ENABLE_BITCODE=YES \
           OTHER_CFLAGS="-fembed-bitcode" \
           BITCODE_GENERATION_MODE=bitcode \
           CODE_SIGNING_REQUIRED=NO \
           clean build | xcpretty -f `xcpretty-travis-formatter` && exit ${PIPESTATUS[0]} || exit 1
