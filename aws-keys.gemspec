# -*- encoding: utf-8 -*-
require File.expand_path("../lib/aws-keys/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "aws-keys"
  s.version     = AwsKeys::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Pieter de Bie"]
  s.email       = ["pieter@pdebie.nl"]
  s.summary     = "Provides an easy way of accessing restricted AWS keys"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
