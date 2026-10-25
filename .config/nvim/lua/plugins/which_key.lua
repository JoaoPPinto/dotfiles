return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			delay = 0,
			spec = {
				{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},
}

-- vim: ts=2 sts=2 sw=2 et
