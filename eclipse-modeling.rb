cask 'eclipse-modeling' do
  version '4.14.0,2019-12'
  sha256 'fb287464dfb09d34c3f121850411f9e4f1f4e9828a2193744420ba9b4fb4fca4'

  url "http://mirror.csclub.uwaterloo.ca/eclipse/technology/epp/downloads/release/2019-12/R/eclipse-modeling-2019-12-R-macosx-cocoa-x86_64.dmg"
  name 'Eclipse Modeling Tools'
  homepage 'https://eclipse.org/'

  # Renamed to avoid conflict with other Eclipse.
  app 'Eclipse.app', target: 'Eclipse Modeling.app'
end
