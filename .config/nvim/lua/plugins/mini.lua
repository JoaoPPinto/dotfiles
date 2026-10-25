return {
	{
		"nvim-mini/mini.icons",
		version = false,
		opts = {},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
}

-- vim: ts=2 sts=2 sw=2 et
