# frozen_string_literal: true

require 'json'

github_cli_output = `gh pr list --json baseRefName,headRefName,url`
json = JSON.parse(github_cli_output)
initial_object = Hash.new { |hash, key| hash[key] = { 'dependents' => [] } }
dependency_hash = json.each_with_object(initial_object) do |pull_request_data, object|
  head_branch = pull_request_data['headRefName']
  base_branch = pull_request_data['baseRefName']
  object[head_branch].merge!(**pull_request_data)
  object[base_branch]['dependents'].push(head_branch)
  object
end
pull_requests_with_dependency = dependency_hash#.select { |_key, value| value['dependents'].size.positive? }

class DepthFirstSearch
  attr_accessor :nodes

  def initialize(nodes)
    @nodes = nodes
  end

  def execute
    search('dev', 0)
    # nodes.keys.each do |branch|
    #   search(branch, 0) if can_enter_node?(branch)
    # end
  end

  def search(node_name, level)
    puts "#{'    ' * level}- [#{node_name}](#{nodes[node_name]['url']})" if nodes[node_name]['dependents'].size.positive? || level > 1
    nodes[node_name][:dfs_in] = true
    nodes[node_name]['dependents'].each do |linked_node|
      raise "Redundant dependency between #{node_name} AND #{linked_node}" if nodes[linked_node][:dfs_in]

      search(linked_node, level + 1) if can_enter_node?(linked_node)
    end
    nodes[node_name][:dfs_out] = true
    nodes[node_name][:dfs_in] = false
  end

  def can_enter_node?(node)
    !nodes[node][:dfs_out]
  end
end

DepthFirstSearch.new(pull_requests_with_dependency).execute
