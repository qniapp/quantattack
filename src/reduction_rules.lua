local reduction_rules = {
  h = {
    -- H          I
    -- H  ----->  I
    {
      "h\nh",
      ",,\n,1,",
      2
    },

    -- H          I
    -- X          I
    -- H  ----->  Z
    {
      "h\nx\nh",
      ",,\n,1,\n,2,z",
      2,
      3
    },

    -- H          I
    -- Z          I
    -- H  ----->  X
    {
      "h\nz\nh",
      ",,\n,1,\n,2,x",
      3,
      3
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
      ",,\ntrue,,\n,1,cnot_x\ntrue,1,control\n,2,\ntrue,2,",
      6,
      10
    },

    -- H            I
    -- S-S  ----->  S-S
    --   H            I
    --
    --   H            I
    -- S-S  ----->  S-S
    -- H            I
    {
      "h\nswap,swap\n?,h",
      ",,\ntrue,2,",
      2,
      5
    },

    -- H            I
    -- X            Z
    -- S-S  ----->  S-S
    --   H            I
    --
    --   H            I
    --   X            Z
    -- S-S  ----->  S-S
    -- H            I
    {
      "h\nx\nswap,swap\n?,h",
      ",,\n,1,z\ntrue,3,",
      3,
      7
    },

    -- H            Z
    -- S-S  ----->  S-S
    --   X            I
    --   H            I
    --
    --   H            Z
    -- S-S  ----->  S-S
    -- X            I
    -- H            I
    {
      "h\nswap,swap\n?,x\n?,h",
      ",,z\ntrue,2,\ntrue,3,",
      3,
      7
    }
  },

  x = {
    -- X          I
    -- X  ----->  I
    {
      "x\nx",
      ",,\n,1,",
      2
    },

    -- X          I
    -- Z  ----->  Y
    {
      "x\nz",
      ",,\n,1,y",
      2,
      2
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
      ",,\ntrue,,\n,2,",
      3,
      8
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
      ",,\n,2,",
      2,
      6
    },

    -- X            I
    -- S-S  ----->  S-S
    --   X            I
    --
    --   X            I
    -- S-S  ----->  S-S
    -- X            I
    {
      "x\nswap,swap\n?,x",
      ",,\ntrue,2,",
      2,
      5
    },

    -- X            Y
    -- S-S  ----->  S-S
    --   Z            I
    --
    --   X            Y
    -- S-S  ----->  S-S
    -- T            I
    {
      "x\nswap,swap\n?,z",
      ",,y\ntrue,2,",
      2,
      6
    }
  },

  y = {
    -- Y          I
    -- Y  ----->  I
    {
      "y\ny",
      ",,\n,1,",
      2
    },

    -- Y            I
    -- S-S  ----->  S-S
    --   Y            I
    --
    --   Y            I
    -- S-S  ----->  S-S
    -- Y            I
    {
      "y\nswap,swap\n?,y",
      ",,\ntrue,2,",
      2,
      5
    }
  },

  z = {
    -- Z          I
    -- Z  ----->  I
    {
      "z\nz",
      ",,\n,1,",
      2
    },

    -- Z          I
    -- X  ----->  Y
    {
      "z\nx",
      ",,\n,1,y",
      2,
      2
    },

    -- Z Z          I I
    -- C-X  ----->  C-X
    --   Z            I
    --
    -- Z Z          I I
    -- X-C  ----->  X-C
    -- Z            I
    {
      "z,z\ncontrol,cnot_x\n?,z",
      ",,\ntrue,,\ntrue,2,",
      3,
      8
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
      ",,\n,2,",
      2,
      6
    },

    -- Z            I
    -- S-S  ----->  S-S
    --   Z            I
    --
    --   Z            I
    -- S-S  ----->  S-S
    -- Z            I
    {
      "z\nswap,swap\n?,z",
      ",,\ntrue,2,",
      2,
      5
    }
  },

  s = {
    -- S          I
    -- S  ----->  Z
    {
      "s\ns",
      ",,\n,1,z",
      2
    },

    -- S          I
    -- Z          I
    -- S  ----->  X
    {
      "s\nz\ns",
      ",,\n,1,\n,2,z",
      3,
      3
    },

    -- S            Z
    -- S-S  ----->  S-S
    --   S            I
    --
    --   S            Z
    -- S-S  ----->  S-S
    -- S            I
    {
      "s\nswap,swap\n?,s",
      ",,z\ntrue,2,",
      2,
      5
    }
  },

  t = {
    -- T          I
    -- T  ----->  S
    {
      "t\nt",
      ",,\n,1,s",
      2
    },

    -- T          I
    -- S          I
    -- T  ----->  Z
    {
      "t\ns\nt",
      ",,\n,1,\n,2,z",
      3,
      3
    },

    -- T          I
    -- Z          I
    -- S          I
    -- T  ----->  I
    {
      "t\nz\ns\nt",
      ",,\n,1,\n,2,\n,3,",
      4,
      4
    },

    -- T          I
    -- S          I
    -- Z          I
    -- T  ----->  I
    {
      "t\ns\nz\nt",
      ",,\n,1,\n,2,\n,3,",
      4,
      4
    },

    -- T            S
    -- S-S  ----->  S-S
    --   T            I
    --
    --   T            S
    -- S-S  ----->  S-S
    -- T            I
    {
      "t\nswap,swap\n?,t",
      ",,s\ntrue,2,",
      2,
      5
    }
  },

  control = {
    -- C-X          I I
    -- C-X  ----->  I I
    --
    -- X-C          I I
    -- X-C  ----->  I I
    {
      "control,cnot_x\ncontrol,cnot_x",
      ",,\ntrue,,\n,1,\ntrue,1,",
      4,
      5
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
      ",,\ntrue,,\n,1,\ntrue,1,\n,2,swap\ntrue,2,swap",
      6,
      10
    },

    --  C-X          I I
    --  S-S  ----->  S-S
    --  X-C          I I
    {
      "control,cnot_x\nswap,swap\ncnot_x,control",
      ",,\ntrue,,\n,2,\ntrue,2,",
      4,
      10
    }
  },

  swap = {
    -- S-S          I
    -- S-S  ----->  I
    {
      "swap,swap\nswap,swap",
      ",,\ntrue,,\n,1,\ntrue,1,",
      4,
      30
    }
  }
}

for first_gate, rules in pairs(reduction_rules) do
  foreach(reduction_rules[first_gate], function(rule)
    rule[1] = transform(split(rule[1], "\n"), split)
    rule[2] = transform(split(rule[2], "\n"), function(to)
      local attrs = split(to)

      -- 簡約でできるゲートはすべて異なるオブジェクトでなくてはならないので、
      -- ルールにはゲートオブジェクトを入れるのではなく、
      -- ゲートのタイプ (gate_type) を入れ、board 側で new する
      return {
        dx = attrs[1] ~= "",
        dy = attrs[2] == "" and nil or tonum(attrs[2]),
        gate_type = attrs[3] == "" and 'i' or attrs[3]
      }
    end)
  end)
end

return reduction_rules
