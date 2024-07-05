# frozen_string_literal: true
# Parse ARGV options and return a OpenStruct with it.

require 'ostruct'
require 'optparse'

class Parser

  def self.parse(args)
    options = OpenStruct.new
    options.template = '- {{url}} <!-- {{branch}} -->'
    options.base_branches = ['master']
    options.open_only = false
    options.debug = false

    OptionParser.new do |opt|
      opt.on('-b', '--base-branches [BRANCH1[,BRANCH2...]]') do |base_branches|
        options.base_branches = base_branches.split(',') if base_branches
      end

      opt.on('-t', '--template [TEMPLATE]', 'Example: \'- {{url}} <!-- {{branch}} -->\' | Available variables: url, branch') do |templates|
        options.template = templates if templates
      end

      opt.on('-o', '--open-only', 'When set, show only open pull requests') do |open_only|
        options.open_only = open_only
      end

      opt.on('-d', '--debug') do |debug|
        options.debug = debug
      end

    end.parse!(args)
    options
  end

end
