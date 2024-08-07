Pod::Spec.new do |spec|
  spec.name     = 'SystemSound'
  spec.summary  = 'Control macOS system volume, mute status, and observe audio device changes with ease.'
  spec.author   = 'sunnyyoung'
  spec.homepage = 'https://github.com/sunnyyoung/SystemSound'
  spec.license  = 'MIT'

  spec.version  = '1.0.0'
  spec.source   = {:git => 'https://github.com/sunnyyoung/SystemSound.git', :tag => spec.version }

  spec.platform      = :osx, '10.13'
  spec.swift_version = '5.0'
  spec.framework     = 'AVFoundation'

  spec.source_files = [
    'Sources/**/*.swift'
  ]
end
