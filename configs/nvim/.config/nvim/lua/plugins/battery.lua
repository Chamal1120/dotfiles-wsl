return {
  "justinhj/battery.nvim",
  config = function()
    require("battery").setup({
      update_rate_seconds = 120,
      show_status_when_no_battery = true,
      method = "sysfs",  -- optional, usually autodetected
    })
  end,
}

