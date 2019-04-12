

local cfg = {}
-- define transformers randomly placed on the map
cfg.hidden_transformers = {
  --[[["Thermite Seller"] = {
    def = {
      title="Thermite Seller", -- menu name
      color={255,55,55}, -- color
      max_units=5,
      units_per_minute=1,
      position={1406.5499267578,3667.5219726562,34.032154083252},
      radius=2, height=1.8, -- area
      recipes = {
        ["Buy"] = { -- action name
          description="Buy thermite.", -- action description
          reagents={
			money = 1000
			}, -- items taken per unit
          products={ -- items given per unit
            items = {
              ["thermite"] = 1
            }
          }
        }
      }
    },
  },
  ["Thermite Seller"] = {
    def = {
      title="Thermite Seller", -- menu name
      color={255,55,55}, -- color
      max_units=5,
      units_per_minute=1,
      position={824.353515625,-2152.15625,29.619012832642},
      radius=2, height=1.8, -- area
      recipes = {
        ["Buy"] = { -- action name
          description="Buy thermite.", -- action description
          reagents={
			money = 1000
			}, -- items taken per unit
          products={ -- items given per unit
            items = {
              ["thermite"] = 1
            }
          }
        }
      }
    },
    positions = {
      {824.353515625,-2152.15625,29.619012832642},
    }
  },]]
  ["Weed field"] = {
    def = {
      title="Weed field", -- menu name
      color={0,200,0}, -- color
      max_units=50,
      units_per_minute=5,
      position={2224.19091796875,5576.9423828125,53.8465042114258},
      radius=10, height=1.8, -- area
      recipes = {
        ["Harvest"] = { -- action name
          description="Harvest weed.", -- action description
          reagents={}, -- items taken per unit
          products={ -- items given per unit
            items = {
              ["weed"] = 5
            }
          }
        }
      }
    },
	positions = {
      {2224.19091796875,5576.9423828125,53.8465042114258},
    }
  },
    ["Weed field"] = {
    def = {
      title="Weed field", -- menu name
      color={0,200,0}, -- color
      max_units=50,
      units_per_minute=5,
      position={1902.1795654296,4858.0366210938,46.738380432128},
      radius=10, height=1.8, -- area
      recipes = {
        ["Harvest"] = { -- action name
          description="Harvest weed.", -- action description
          reagents={}, -- items taken per unit
          products={ -- items given per unit
            items = {
              ["weed"] = 5
            }
          }
        }
      }
    },
	positions = {
      {1902.1795654296,4858.0366210938,46.738380432128},
    }
  },
    ["Coca leaf exchange"] = {
    def = {
      title="Coca leaf exchange", -- menu name
      color={0,200,0}, -- color
      max_units=20,
      units_per_minute=2,
      position={2576.3547363282,4650.3520507812,34.064353942872},
      radius=6, height=1.8, -- area
      recipes = {
        ["Harvest"] = { -- action name
          description="Harvest weed.", -- action description
          reagents={
			money = 15
		  }, -- items taken per unit
          products={ -- items given per unit
            items = {
              ["coca_leaf"] = 1
            }
          }
        }
      }
    },
	positions = {
      {2576.3547363282,4650.3520507812,34.064353942872},
    }
  },
    ["Coca leaf exchange"] = {
    def = {
      title="Coca leaf exchange", -- menu name
      color={0,200,0}, -- color
      max_units=20,
      units_per_minute=2,
      position={2194.591796875,5599.32421875,53.714111328125},
      radius=6, height=1.8, -- area
      recipes = {
        ["Harvest"] = { -- action name
          description="Harvest weed.", -- action description
          reagents={
			money = 15
		  }, -- items taken per unit
          products={ -- items given per unit
            items = {
              ["coca_leaf"] = 1
            }
          }
        }
      }
    },
	positions = {
      {2194.591796875,5599.32421875,53.714111328125},
    }
  },
  
  --[[
  ["Weed processing"] = {
    def = {
      title="Weed processing", -- menu name
      color={0,200,0}, -- color
      max_units=1000,
      units_per_minute=1000,
      position={0,0,0},
      radius=8, height=1.8, -- area
      recipes = {
        ["Process"] = { -- action name
          description="Process weed.", -- action description
          reagents={
            items = {
              ["weed"] = 2,
              ["demineralized_water"] = 1
            }
          }, -- items taken per unit
          products={ -- items given per unit
            items = {
              ["weed_processed"] = 1
            }
          }
        }
      },
      permissions = {
        "!aptitude.science.chemicals.>4"
      }
    },
    positions = {
      {1443.16345214844,6332.486328125,23.981897354126},
      {1581.90747070313,2910.68334960938,56.9333839416504},
      {2154.8515625,3386.4052734375,45.5702743530273}
    }
  },
  ["Weed resale"] = {
    def = {
      title="Weed resale", -- menu name
      color={0,200,0}, -- color
      max_units=1000,
      units_per_minute=1000,
      position={0,0,0}, -- pos
      radius=5, height=1.8, -- area
      recipes = {
        ["Sell"] = { -- action name
          description="Sell processed weed.", -- action description
          reagents={
            items = {
              ["weed_processed"] = 10
            }
          }, -- items taken per unit
          products={ -- items given per unit
            items = {
              ["dirty_money"] = 5000
            }
          }
        }
      }
    },
    positions = {
      {-410.352722167969,447.736328125,112.580322265625},
      {-1907.70776367188,292.63720703125,88.6077499389648},
      {-970.378356933594,-1121.73522949219,2.17184591293335},
      {340.481842041016,-1856.76635742188,27.3206825256348},
      {-585.191833496094,-1606.83642578125,27.010814666748},
      {238.181610107422,-2021.85290527344,18.3191604614258}
    }
  }]]
}

-- time in minutes before hidden transformers are relocated (min is 5 minutes)
cfg.hidden_transformer_duration = 1 -- 5 days

-- configure the information reseller (can sell hidden transformers positions)
cfg.informer = {
  infos = {
    --["Weed field"] = 25000,
    --["Weed processing"] = 25000,
    --["Weed resale"] = 25000
  },
  positions = {
	{0,0,0}
    --{1821.12390136719,3685.9736328125,34.2769317626953},
    --{1804.2958984375,3684.12280273438,34.217945098877}
  },
  interval = 30, -- interval in minutes for the reseller respawn
  duration = 10, -- duration in minutes of the spawned reseller
  map_entity = {"PoI", {blip_id = 133, blip_id = 2, marker_id = 1}} -- {ent,cfg} will fill cfg.title, cfg.pos
}

return cfg
