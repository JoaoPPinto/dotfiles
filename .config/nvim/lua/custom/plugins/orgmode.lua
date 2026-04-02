return {
	"nvim-orgmode/orgmode",
	event = "VeryLazy",
	config = function()
		require("orgmode").setup({
			org_agenda_files = "~/orgfiles/**/*",
			org_default_notes_file = "~/orgfiles/refile.org",
			org_todo_keywords = {
				"TODO(t)",
				"PLANNING(p)",
				"IN_PROGRESS(i)",
				"BLOCKED(b)",
				"VERIFYING(v)",
				"|",
				"DONE(d)",
				"WONT_DO(w)",
			},
			org_todo_keyword_faces = {
				TODO = ':foreground "GoldenRod" :weight bold',
				PLANNING = ':foreground "DeepPink" :weight bold',
				IN_PROGRESS = ':foreground "Cyan" :weight bold',
				BLOCKED = ':foreground "Red" :weight bold',
				VERIFYING = ':foreground "DarkOrange" :weight bold',
				DONE = ':foreground "LimeGreen" :weight bold',
				WONT_DO = ':foreground "LimeGreen" :weight bold',
			},
			org_capture_templates = {
				j = {
					description = "Work Log Entry",
					target = "~/orgmode/work-log.org",
					datetree = { reversed = true },
					template = "* %?",
					properties = { empty_lines = 0 },
				},
				g = {
					description = "General To-Do",
					target = "~/orgmode/todo.org",
					headline = "General TODO",
					template = "* TODO [#B] %?\n:Created: %T\n ",
					properties = {
						empty_lines = 0,
					},
				},
			},
		})
		-- Experimental LSP support
		vim.lsp.enable("org")
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "org",
			callback = function()
				vim.keymap.set("i", "<S-CR>", '<cmd>lua require("orgmode").action("org_mappings.meta_return")<CR>', {
					silent = true,
					buffer = true,
				})
			end,
		})
	end,
}
