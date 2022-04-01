# frozen_string_literal: true

require 'json'

main_branch = if ARGV[1]
                ARGV[1]
              else
                puts "Branch not specified. Using master"
                'master'
              end
github_cli_output = `gh pr list -L 999 --json baseRefName,headRefName,url`
json = JSON.parse(github_cli_output)
initial_object = Hash.new { |hash, key| hash[key] = {'dependents' => []} }
dependency_hash = json.each_with_object(initial_object) do |pull_request_data, object|
  head_branch = pull_request_data['headRefName']
  base_branch = pull_request_data['baseRefName']
  object[head_branch].merge!(**pull_request_data)
  object[base_branch]['dependents'].push(head_branch)
  object
end
pull_requests_with_dependency = dependency_hash #.select { |_key, value| value['dependents'].size.positive? }

class DepthFirstSearch
  attr_accessor :nodes, :visited

  def initialize(nodes)
    @nodes = nodes
    @visited = Hash.new { |hash, key| hash[key] = {} }
  end

  def execute(starting_node)
    search(starting_node, 0)
    # nodes.keys.each do |branch|
    #   search(branch, 0) if can_enter_node?(branch)
    # end
  end

  def search(current_node, level)
    puts "#{'    ' * level}- [#{current_node}](#{nodes[current_node]['url']})" if nodes[current_node]['dependents'].size.positive? || level > 1
    visited[current_node][:dfs_in] = true
    nodes[current_node]['dependents'].each do |dependent_node|
      raise "Redundant dependency between #{current_node} AND #{dependent_node}" if visited[dependent_node][:dfs_in]

      search(dependent_node, level + 1) if can_enter_node?(dependent_node)
    end
    visited[current_node][:dfs_out] = true
    visited[current_node][:dfs_in] = false
  end

  def can_enter_node?(node)
    !visited[node][:dfs_out]
  end
end

DepthFirstSearch.new(pull_requests_with_dependency).execute(main_branch)
