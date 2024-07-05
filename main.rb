# frozen_string_literal: true

require 'json'
require 'optparse'
require_relative './parser'
require_relative './depth_first_search'


options = Parser.parse(ARGV)

pr_limits = 40000
pr_attributes = 'baseRefName,headRefName,url,state'

debug_string = "gh pr list --state open -L #{pr_limits} --json #{pr_attributes}"
puts debug_string if options.debug
open_prs = JSON.parse(`#{debug_string}`)


merged_prs = if options.open_only
               []
             else
               exclude_base = options.base_branches.map { |base_branch| "-base:#{base_branch}" }.join(' ')

               debug_string = "gh pr list --state merged -L #{pr_limits} --json #{pr_attributes} --search \"#{exclude_base}\""
               puts debug_string if options.debug
               JSON.parse(`#{debug_string}`)
             end

json = open_prs + merged_prs

initial_object = Hash.new { |hash, key| hash[key] = { 'dependents' => [] } }
dependency_hash = json.each_with_object(initial_object) do |pull_request_data, object|
  head_branch = pull_request_data['headRefName']
  base_branch = pull_request_data['baseRefName']
  object[head_branch].merge!(**pull_request_data)
  object[base_branch]['dependents'].push(head_branch)
  object
end

output = options.base_branches.map do |base_branch|
  "<!-- PULL REQUEST TRAIN FROM THE BASE BRANCH #{base_branch} -->\n#{DepthFirstSearch.new(dependency_hash, options: options).execute(base_branch)}"
end.join("\n\n")
puts output
