#!/bin/ruby
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib)
require 'rubygems'
require 'bundler/setup'
require 'colorize'
require 'byebug'

require 'game'
game = Game.new
game.main_loop
