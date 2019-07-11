local cfg = {}

cfg.remove_interval = 1000 -- number of milliseconds between two remove check

-- Veh model blacklist, names (string) or hashes (number)
cfg.veh_models = {
  "police",
  "ambulance",
  "policeb",
  "police2",
  "police3",
  1938952078 --FireTruck (firetruk <= model name)
}

return cfg
