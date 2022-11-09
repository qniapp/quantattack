require("engine/test/bustedhelper")
require("board")
require("qpu")
require("player_cursor")

local game_class = require("game")
local profiler = require("profiler")

describe('パフォーマンス', function()
  it("QPU vs QPU のプロファイルを取る", function()
    local qpu1_board = create_board()
    local qpu2_board = create_board()
    local qpu1_cursor = create_player_cursor(qpu1_board)
    local qpu2_cursor = create_player_cursor(qpu2_board)
    local qpu1 = create_qpu(qpu1_cursor)
    local qpu2 = create_qpu(qpu2_cursor)
    local game = game_class()

    qpu1:init()
    qpu1_board:initialize_with_random_gates()
    qpu1_board.attack_cube_target = { 78, 15 }
    qpu1_cursor:init()

    qpu2:init()
    qpu2_board:initialize_with_random_gates()
    qpu2_board.attack_cube_target = { 48, 15, "left" }
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
