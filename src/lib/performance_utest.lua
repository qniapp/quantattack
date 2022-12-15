require("engine/test/bustedhelper")
require("lib/board")
require("lib/qpu")

local game_class = require("lib/game")
local cursor_class = require("lib/cursor")
local profiler = require("lib/profiler")

describe('パフォーマンス', function()
  it("QPU vs QPU のプロファイルを取る", function()
    local qpu1_board = create_board()
    local qpu2_board = create_board()
    local qpu1_cursor = cursor_class(qpu1_board)
    local qpu2_cursor = cursor_class(qpu2_board)
    local qpu1 = create_qpu(qpu1_cursor, qpu1_board)
    local qpu2 = create_qpu(qpu2_cursor, qpu2_board)
    local game = game_class()

    qpu1:init()
    qpu1_board:put_random_gates()
    qpu1_board.gate_offset_target = { 48, 15 }
    qpu1_board.attack_cube_target = { 78, 15 }
    qpu1_cursor:init()

    qpu2:init()
    qpu2_board:put_random_gates()
    qpu2_board.gate_offset_target = { 78, 15 }
    qpu2_board.attack_cube_target = { 48, 15 }
    qpu2_cursor:init()

    game:init()
    game:add_player(qpu1, qpu1_cursor, qpu1_board, qpu2_board)
    game:add_player(qpu2, qpu2_cursor, qpu2_board, qpu1_board)

    profiler.start()
    for i = 1, 2000 do
      game:update()
    end
    profiler.stop()

    profiler.report("profiler.log")
  end)
end)
