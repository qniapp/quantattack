#!/usr/bin/env ruby
# frozen_string_literal: true

#
# ファイルから読み込んだパターン文字列を空行で区切ったもの
#
def aa_patterns
  File.read(ARGV[0]).split(/\n{2,}/)
end

def parse_pattern(string)
  score = nil
  gates = []
  reduce_to = []

  string.split("\n").each_with_index do |each, lineno|
    if lineno.zero?
      # 一行目は点数
      score = each.to_i
    else
      case each
      when /^│\sH\s│.*([I|X|Y|Z])/ # パターン一列目の H
        gates << 'h'
        reduce_to << { dx: 0, dy: 1 - gates.length,
                       block_type: Regexp.last_match(1) == 'I' ? '' : Regexp.last_match(1).downcase }
      when /^\s+│\sH\s│.*([I|X|Y|Z])/ # パターン二列目の H
        gates << '?,h'
        reduce_to << { dx: true, dy: 1 - gates.length,
                       block_type: Regexp.last_match(1) == 'I' ? '' : Regexp.last_match(1).downcase }
      when /^│\sX\s│.*([I|X|Y|Z])/ # パターン一列目の X
        gates << 'x'
        # reduce_to << { dx: 0, dy: 1 - gates.length, block_type: '' }
        reduce_to << { dx: 0, dy: 1 - gates.length,
                       block_type: Regexp.last_match(1) == 'I' ? '' : Regexp.last_match(1).downcase }
      when /^\s+│\sX\s│.*([I|X|Y|Z])/ # パターン二列目の X
        gates << '?,x'
        reduce_to << { dx: true, dy: 1 - gates.length,
                       block_type: Regexp.last_match(1) == 'I' ? '' : Regexp.last_match(1).downcase }
      when /^│\sY\s│.*([I|X|Y|Z])/ # パターン一列目の Y
        gates << 'y'
        reduce_to << { dx: 0, dy: 1 - gates.length,
                       block_type: Regexp.last_match(1) == 'I' ? '' : Regexp.last_match(1).downcase }
      when /^\s+│\sY\s│.*([I|X|Y|Z])/ # パターン二列目の Y
        gates << '?,y'
        reduce_to << { dx: 0, dy: 1 - gates.length,
                       block_type: Regexp.last_match(1) == 'I' ? '' : Regexp.last_match(1).downcase }
      when /^│\sZ\s│.*([I|X|Y|Z])/ # パターン一列目の Z
        gates << 'z'
        reduce_to << { dx: 0, dy: 1 - gates.length,
                       block_type: Regexp.last_match(1) == 'I' ? '' : Regexp.last_match(1).downcase }
      when /^\s+│\sZ\s│.*([I|X|Y|Z])/ # パターン二列目の Z
        gates << '?,z'
        reduce_to << { dx: 0, dy: 1 - gates.length,
                       block_type: Regexp.last_match(1) == 'I' ? '' : Regexp.last_match(1).downcase }
      when /^\s\sX─+X/
        gates << 'swap,swap'
      end
    end
  end

  [score, gates, reduce_to]
end

aa_patterns.each do |pattern|
  puts pattern

  score, gates, reduce_to = parse_pattern(pattern)

  gates_string = gates.join("\n")
  reduce_to_string = reduce_to.map do |each|
    dx = each[:dx] == true ? true : ''
    dy = (each[:dy]).zero? ? '' : each[:dy]
    block_type = each[:block_type]

    "#{dx},#{dy},#{block_type}"
  end.join("\n")

  p "#{gates_string}|#{reduce_to_string}|#{score}"
  puts
end
