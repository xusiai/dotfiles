local M = {}

M.base_30 = {
   white = "#FFFCFF",
   darker_black = "#0A0D0F",
   black = "#0A0D0F", 
   black2 = "#0A0D0F",
   one_bg = "#0A0D0F", 
   one_bg2 = "#0F1214",
   one_bg3 = "#141719",
   grey = "#0A0D0F",
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
   cyan = "#93e6f5",
   statusline_bg = "#0A0D0F",
   lightbg = "#0A0D0F",
   pmenu_bg = "#B4F8C8",
   folder_bg = "#ffccda",
   lavender = "#ebdeff",
}

M.base_16 = {
   base00 = "#0A0D0F",
   base01 = "#0F1214",
   base02 = "#141719",
   base03 = "#0A0D0F",
   base04 = "#1e2123",
   base05 = "#F5E8FF",
   base06 = "#FFF2FF",
   base07 = "#FFFCFF",
   base08 = "#FFB2AD",
   base09 = "#FFDCAC",
   base0A = "#FAE3B0",
   base0B = "#B4F8C8",
   base0C = "#BFFBF9",
   base0D = "#ffccda",
   base0E = "#D2C5E8",
   base0F = "#FFB2AD",
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

