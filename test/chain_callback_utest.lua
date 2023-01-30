require("engine/test/bustedhelper")
require("test/test_helper")
require("lib/effect_set")
require("lib/player")
require("lib/game")
require("lib/board")
require("lib/block")

local match = require("luassert.match")

describe('chain', function()
  local board
  local player

  before_each(function()
    stub(game_class, "chain_callback")
    board = board_class()
    board.attack_ion_target = { 85, 30 }
    player = player_class()
  end)

  it("コールバックが呼ばれる", function()
    --    Y           Y          Y
    -- [X H]        H X
    --  H X  -----> H X ----->     ----->   Y
    --  Y Y         Y Y        Y Y        Y Y
    board:put(2, 4, block_class("y"))
    board:put(1, 3, block_class("x"))
    board:put(2, 3, block_class("h"))
    board:put(1, 2, block_class("h"))
    board:put(2, 2, block_class("x"))
    board:put(1, 1, block_class("y"))
    board:put(2, 1, block_class("y"))

    board:swap(1, 3)

    local chain_callback = assert.spy(game_class.chain_callback)

    wait_swap_to_finish(board)

    -- TODO: update 回数を式として書く
    for _i = 1, 200 do
      board:update(game_class, player)
    end

    chain_callback.was_called(1)
    chain_callback.was_called_with("2,3", 2, board:screen_x(2), board:screen_y(2), match._, match._, match._)
  end)

  it("コールバックが呼ばれる", function()
    local chain_callback = assert.spy(game_class.chain_callback)

    -- G G G      X Y Z
    -- H     --->       --->
    -- H Y          Y        X   Z
    board:put(1, 3, garbage_block(3))
    board:put(1, 2, block_class("h"))
    board:put(1, 1, block_class("h"))
    board:put(2, 1, block_class("y"))

    -- HH とおじゃまブロックがマッチ
    board:update()

    -- おじゃまブロックの一番左が分解
    for i = 1, block_class.block_match_animation_frame_count do
      board:update()
    end

    -- おじゃまブロックの真ん中が分解
    for i = 1, block_class.block_match_delay_per_block do
      board:update()
    end

    -- おじゃまブロックの一番右が分解
    for i = 1, block_class.block_match_delay_per_block do
      board:update()
    end

    -- 分解してできたブロックすべてのフリーズ解除
    for i = 1, block_class.block_match_delay_per_block do
      board:update()
    end
    board:update()

    -- 下の Y とマッチするように
    -- おじゃまブロック真ん中が分解してできたブロックを Y にする
    board:block_at(2, 3).type = "y"

    -- TODO: update 回数を式として書く
    for _i = 1, 200 do
      board:update(game_class, player)
    end

    chain_callback.was_called(1)
    chain_callback.was_called_with("1,2", 2, board:screen_x(2), board:screen_y(2), match._, match._, match._)
  end)
end)
