# frozen_string_literal: true

require 'json'

STATE_OPEN = "OPEN"

links_only = !ARGV.include?('--formatted')
main_branch = if ARGV[1]
                ARGV[1]
              else
                puts "Branch not specified. Using master"
                'master'
              end
open_prs = JSON.parse(`gh pr list --state open -L 40000 --json baseRefName,headRefName,url,state`)
merged_prs = JSON.parse(`gh pr list --state merged -L 40000 --json baseRefName,headRefName,url,state --search "-base:master"`)
json = open_prs + merged_prs
initial_object = Hash.new { |hash, key| hash[key] = { 'dependents' => [] } }
dependency_hash = json.each_with_object(initial_object) do |pull_request_data, object|
  head_branch = pull_request_data['headRefName']
  base_branch = pull_request_data['baseRefName']
  object[head_branch].merge!(**pull_request_data)
  object[base_branch]['dependents'].push(head_branch)
  object
end
pull_requests_with_dependency = dependency_hash #.select { |_key, value| value['dependents'].size.positive? }

class DepthFirstSearch

  def initialize(nodes, links_only: true)
    @nodes = nodes
    @visited = Hash.new { |hash, key| hash[key] = {} }
    @links_only = links_only
  end

  def execute(starting_node)
    string = search(starting_node, 0, any_open_pr_in_this_branch: false)
    puts "- #{starting_node}\n#{string}"
    # nodes.keys.each do |branch|
    #   search(branch, 0) if can_enter_node?(branch)
    # end
  end

  def search(current_node, level, any_open_pr_in_this_branch:)
    visited[current_node][:dfs_in] = true
    new_any_open_pr_in_this_branch = any_open_pr_in_this_branch || nodes[current_node]['state'] == STATE_OPEN

    dependents_strings = nodes[current_node]['dependents'].map do |dependent_node|
      if visited[dependent_node][:dfs_in]
        puts "Redundant dependency between #{current_node} AND #{dependent_node}"
        next
      end

      search(dependent_node, level + 1, any_open_pr_in_this_branch: new_any_open_pr_in_this_branch) if can_enter_node?(dependent_node)
    end
    dependents_strings = dependents_strings.compact.join("\n")

    visited[current_node][:dfs_out] = true
    visited[current_node][:dfs_in] = false

    return nil if !new_any_open_pr_in_this_branch && dependents_strings.empty?

    current_node_string = if links_only
                            "#{'    ' * [level - 1, 0].max}- #{nodes[current_node]['url']}<!-- #{current_node} -->" if nodes[current_node]['dependents'].size.positive? || level > 1
                          else
                            "#{'    ' * level}- [#{current_node}](#{nodes[current_node]['url']})" if nodes[current_node]['dependents'].size.positive? || level > 1
                          end
    return current_node_string if dependents_strings.empty?
    "#{current_node_string}\n#{dependents_strings}"
  end

  def can_enter_node?(node)
    !visited[node][:dfs_out]
  end

  private

  attr_accessor :nodes, :visited, :links_only

end

DepthFirstSearch.new(pull_requests_with_dependency, links_only: links_only).execute(main_branch)
