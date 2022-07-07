local M = {}

M.base_30 = {
   white = "#fff7ff",
   darker_black = "#05080a",
   black = "#05080a", 
   black2 = "#05080a",
   one_bg = "#05080a", 
   one_bg2 = "#0F1214",
   one_bg3 = "#141719",
   grey = "#05080a",
   grey_fg = "#FFF2FF",
   grey_fg2 = "#F5E8FF",
   light_grey = "#FAEDFF",
   red = "#FFB2AD",
   baby_pink = "#ffc2d0",
   pink = "#FFBDCB",
   line = "#1e2123", 
   green = "#B4F8C8",
   vibrant_green = "#b9fdcd",
   nord_blue = "#BFFBF9",
   blue = "#c4fffe",
   yellow = "#FFFFC1",
   sun = "#ffe6b6",
   purple = "#dccff2",
   dark_purple = "#D2C5E8",
   teal = "#bff2ea",
   orange = "#FFDCAC",
   cyan = "#9eecdf",
   statusline_bg = "#05080a",
   lightbg = "#05080a",
   pmenu_bg = "#B4F8C8",
   folder_bg = "#ffccda",
   lavender = "#ebdeff",
}

M.base_16 = {
   base00 = "#05080a",
   base01 = "#0A0D0F",
   base02 = "#0f1214",
   base03 = "#141719",
   base04 = "#C4FFFE",
   base05 = "#fff7ff",
   base06 = "#f0e3ff",
   base07 = "#e6d9fc",
   base08 = "#ffc2d0",
   base09 = "#d7caed",
   base0A = "#b9fdcd",
   base0B = "#ffffc6",
   base0C = "#9eecdf",
   base0D = "#93e6f5",
   base0E = "#d7caed",
   base0F = "#b9fdcd",
}

M.polish_hl = {
   TSVariable = {
      fg = M.base_30.lavender,
   },

   TSProperty = {
      fg = M.base_30.teal,
   },

   TSVariableBuiltin = {
      fg = M.base_30.red,
   },
}

M.type = "dark"

M = require("base46").override_theme(M, "SAGA")

return M

