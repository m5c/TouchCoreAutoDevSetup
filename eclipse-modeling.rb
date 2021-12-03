cask 'eclipse-modeling' do
  version '4.17.0,2020-09'
  sha256 '4121cfdf9390ff94fd1a2812cf3296c76f121ec4a3402e01aca514c58c8b2b0b'

  url "https://www.cs.mcgill.ca/~mschie3/eclipse-modeling-2020-09-R-macosx-cocoa-x86_64.dmg"
  name 'Eclipse Modeling Tools'
  homepage 'https://eclipse.org/'

  # Renamed to avoid conflict with other Eclipse.
  app 'Eclipse.app', target: 'Eclipse Modeling.app'
end
