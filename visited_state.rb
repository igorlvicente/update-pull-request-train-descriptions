class VisitedState
  def initialize
    @nodes = Hash.new { |hash, key| hash[key] = { in: false, left: false }}
  end

  def enter(node)
    nodes[node][:in] = true
  end

  def leave(node)
    nodes[node][:in] = false
    nodes[node][:left] = true
  end

  def in?(node)
    nodes[node][:in]
  end

  def left?(node)
    nodes[node][:left]
  end

  private

  attr_accessor :nodes
end
