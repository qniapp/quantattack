local x_gate = require("x_gate")
local y_gate = require("y_gate")
local z_gate = require("z_gate")
local s_gate = require("s_gate")
local control_gate = require("control_gate")
local cnot_x_gate = require("cnot_x_gate")
local swap_gate = require("swap_gate")

local reduction_rules = {
  h = {
    -- H          I
    -- H  ----->  I
    {
      "h\nh",
      ",,\n,1,"
    },

    -- H          I
    -- X          I
    -- H  ----->  Z
    {
      "h\nx\nh",
      ",,\n,1,\n,2,z"
    },

    -- H          I
    -- Z          I
    -- H  ----->  X
    {
      "h\nz\nh",
      ",,\n,1,\n,2,x"
    },

    -- H H          I I
    -- C-X  ----->  X-C
    -- H H          I I
    --
    -- H H          I I
    -- X-C  ----->  C-X
    -- H H          I I
    {
      "h,h\ncontrol,cnot_x\nh,h",
      ",,\ntrue,,\n,1,cnot_x\ntrue,1,control\n,2,\ntrue,2,"
    },

    -- H            I
    -- S-S  ----->  S-S
    --   H            I
    --
    --   H            I
    -- S-S  ----->  S-S
    -- H            I
    {
      "h\nswap,swap\ni,h",
      ",,\ntrue,2,"
    }
  },

  x = {
    -- X          I
    -- X  ----->  I
    {
      "x\nx",
      ",,\n,1,"
    },

    -- X          I
    -- Z  ----->  Y
    {
      "x\nz",
      ",,\n,1,y"
    },

    -- X X          I I
    -- C-X  ----->  C-X
    -- X            I
    --
    -- X X          I I
    -- X-C  ----->  X-C
    --   X            I
    {
      "x,x\ncontrol,cnot_x\nx",
      ",,\ntrue,,\n,2,"
    },

    -- X            I
    -- X-C  ----->  X-C
    -- X            I
    --
    --   X            I
    -- C-X  ----->  C-X
    --   X            I
    {
      "x\ncnot_x,control\nx",
      ",,\n,2,"
    },

    -- X            I
    -- S-S  ----->  S-S
    --   X            I
    --
    --   X            I
    -- S-S  ----->  S-S
    -- X            I
    {
      "x\nswap,swap\ni,x",
      ",,\ntrue,2,"
    }
  },

  y = {
    -- Y          I
    -- Y  ----->  I
    {
      "y\ny",
      ",,\n,1,"
    },

    -- Y            I
    -- S-S  ----->  S-S
    --   Y            I
    --
    --   Y            I
    -- S-S  ----->  S-S
    -- Y            I
    {
      "y\nswap,swap\ni,y",
      ",,\ntrue,2,"
    }
  },

  z = {
    -- Z          I
    -- Z  ----->  I
    {
      "z\nz",
      ",,\n,1,"
    },

    -- Z          I
    -- X  ----->  Y
    {
      "z\nx",
      ",,\n,1,y"
    },

    -- Z Z          I I
    -- C-X  ----->  C-X
    --   Z            I
    --
    -- Z Z          I I
    -- X-C  ----->  X-C
    -- Z            I
    {
      "z,z\ncontrol,cnot_x\ni,z",
      ",,\ntrue,,\ntrue,2,"
    },

    -- Z            I
    -- C-X  ----->  C-X
    -- Z            I
    --
    --   Z            I
    -- X-C  ----->  X-C
    --   Z            I
    {
      "z\ncontrol,cnot_x\nz",
      ",,\n,2,"
    },

    -- Z            I
    -- S-S  ----->  S-S
    --   Z            I
    --
    --   Z            I
    -- S-S  ----->  S-S
    -- Z            I
    {
      "z\nswap,swap\ni,z",
      ",,\ntrue,2,"
    }
  },

  s = {
    -- S          I
    -- S  ----->  Z
    {
      "s\ns",
      ",,\n,1,z"
    },

    -- S          I
    -- Z          I
    -- S  ----->  X
    {
      "s\nz\ns",
      ",,\n,1,\n,2,z"
    },

    -- S            Z
    -- S-S  ----->  S-S
    --   S            I
    --
    --   S            Z
    -- S-S  ----->  S-S
    -- S            I
    {
      "s\nswap,swap\ni,s",
      ",,z\ntrue,2,"
    }
  },

  t = {
    -- T          I
    -- T  ----->  S
    {
      "t\nt",
      ",,\n,1,s"
    },

    -- T          I
    -- S          I
    -- T  ----->  Z
    {
      "t\ns\nt",
      ",,\n,1,\n,2,z"
    },

    -- T          I
    -- Z          I
    -- S          I
    -- T  ----->  I
    {
      "t\nz\ns\nt",
      ",,\n,1,\n,2,\n,3,"
    },

    -- T          I
    -- S          I
    -- Z          I
    -- T  ----->  I
    {
      "t\ns\nz\nt",
      ",,\n,1,\n,2,\n,3,"
    },

    -- T            S
    -- S-S  ----->  S-S
    --   T            I
    --
    --   T            S
    -- S-S  ----->  S-S
    -- T            I
    {
      "t\nswap,swap\ni,t",
      ",,s\ntrue,2,"
    }
  },

  control = {
    -- C-X          I
    -- C-X  ----->  I
    --
    -- X-C          I
    -- X-C  ----->  I
    {
      "control,cnot_x\ncontrol,cnot_x",
      ",,\ntrue,,\n,1,\ntrue,1,"
    },

    -- C-X          I I
    -- X-C          I I
    -- C-X  ----->  S-S
    --
    -- X-C          I I
    -- C-X          I I
    -- X-C  ----->  S-S
    {
      "control,cnot_x\ncnot_x,control\ncontrol,cnot_x",
      ",,\ntrue,,\n,1,\ntrue,1,\n,2,swap\ntrue,2,swap"
    },

    --  C-X          I I
    --  S-S  ----->  S-S
    --  X-C          I I
    {
      "control,cnot_x\nswap,swap\ncnot_x,control",
      ",,\ntrue,,\n,2,\ntrue,2,"
    }
  },

  swap = {
    -- S-S          I
    -- S-S  ----->  I
    {
      "swap,swap\nswap,swap",
      ",,\ntrue,,\n,1,\ntrue,1,"
    }
  }
}

for first_gate, rules in pairs(reduction_rules) do
  foreach(reduction_rules[first_gate], function(rule)
    rule[1] = transform(split(rule[1], "\n"), split)
    rule[2] = transform(split(rule[2], "\n"), function(to)
      local attrs = split(to)
      local gates = { x = x_gate(), y = y_gate(), z = z_gate(), s = s_gate(), control = control_gate(),
        cnot_x = cnot_x_gate(), swap = swap_gate() }

      return { dx = attrs[1] ~= "",
        dy = attrs[2] == "" and nil or tonum(attrs[2]),
        gate = gates[attrs[3]] }
    end)
  end)
end

return reduction_rules
