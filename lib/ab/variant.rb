class Variant < Struct.new(:hash, :accumulated_chance_weight)
  def chance_weight
    hash['chance_weight']
  end

  def name
    hash['name']
  end
end
