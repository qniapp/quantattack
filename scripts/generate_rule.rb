#!/usr/bin/env ruby
# frozen_string_literal: true

score = nil
gates = []
reduce_to = []

File.read(ARGV[0]).split("\n").each_with_index do |each, lineno|
  if lineno.zero?
    # 一行目は点数
    score = each.to_i
  else
    case each
    when /^│\sH/
      gates << 'h'
      reduce_to << ['h', 1 - gates.length]
    end
  end
end

gates_string = gates.join("\n")
reduce_to_string = reduce_to.map do |each|
  # dx, dy, block_type をカンマでつなげたものを返す。
  dx = '' # 一列のパターンと仮定
  dy = (each[1]).zero? ? '' : each[1]
  block_type = '' # 消えて I になると仮定

  "#{dx},#{dy},#{block_type}"
end.join("\n")

p "#{gates_string}|#{reduce_to_string}|#{score}"
