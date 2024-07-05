require_relative './visited_state'

# Navigates the dependency hash and returns a string to be printed for the pull request trees
class DepthFirstSearch

  STATE_OPEN = "OPEN"

  def initialize(nodes, options:)
    @nodes = nodes
    @visited = VisitedState.new
    @options = options
  end

  # @param level [Integer]
  def execute(current_node, level = 0, any_open_node: false)
    visited.enter(current_node)

    new_any_open_node = any_open_node || nodes[current_node]['state'] == STATE_OPEN

    dependent_nodes = nodes[current_node]['dependents']
    current_node_name = nodes[current_node]['headRefName'] || current_node

    dependents_strings = dependent_nodes.map do |dependent_node|
      next if visited.left?(dependent_node)
      if visited.in?(dependent_node)
        puts "Circular graph between #{current_node} AND #{dependent_node}"
        next
      end

      execute(dependent_node, level + 1, any_open_node: new_any_open_node)
    end

    dependents_strings = dependents_strings.compact.join("\n")

    visited.leave(current_node)

    # Doesn't print base branches
    return dependents_strings if level.zero?

    # Last node and no open PR in the tree
    return nil if !new_any_open_node && dependents_strings.empty?

    # Will only be printed when has dependents or is a dependent (i.e., has level of a non-base dependent)
    return nil if dependent_nodes.empty? && level <= 1

    filled_template = options.template.gsub('{{url}}', nodes[current_node]['url']).gsub('{{branch}}', current_node_name)
    current_node_string = "#{'    ' * [level - 1, 0].max}#{filled_template}"

    # If has no dependent, print only itself (and no \n)
    return current_node_string if dependents_strings.empty?

    "#{current_node_string}\n#{dependents_strings}"
  end

  private

  attr_accessor :nodes, :visited, :options

end
