# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'motion-config-vars'

begin
  require 'bundler'
  Bundler.require
  require "awesome_print_motion"
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Karaoke'
  app.vendor_project('vendor/Spotify.framework', :static, :products => ['Spotify'], :headers_dir => 'Headers')
  app.info_plist['CFBundleURLTypes'] = [{'CFBundleURLName' => 'com.sambauch.karaoke-genius-spotify-login', 'CFBundleURLSchemes' => ['karaoke-genius-spotify'] }]
  app.fonts += ['PT DIN Condensed Cyrillic.ttf']

end

desc 'Build against production server'
task :prod do
  ENV['API_ENV'] = 'prod'
  Rake::Task["simulator"].invoke
end

desc 'Build against local server'
task :dev do
  ENV['API_ENV'] = 'dev'
  Rake::Task["simulator"].invoke
end
