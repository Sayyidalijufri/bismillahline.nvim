local M = {}
local utils = require("bismillahline.utils")
local quotes = require("bismillahline.quotes")

-- Default configuration
M.config = {
	theme = "auto", -- "auto", "dark", "light"
	style = "slant", -- "slant", "round", "block"
	sections = {
		mode = true,
		git = true,
		file = true,
		diagnostics = true,
		system = true,
		datetime = true,
	},
	icons = {
		mode = {
			normal = "󰆧",
			insert = "󰏫",
			visual = "󰈈",
			command = "",
			terminal = "",
			replace = "󰛔",
		},
		git = {
			branch = "",
			added = "",
			modified = "",
			removed = "",
		},
		file = {
			default = "",
			modified = "",
			readonly = "",
		},
		diagnostics = {
			error = "",
			warn = "",
			info = "",
			hint = "",
		},
		system = {
			linux = "",
			macos = "",
			windows = "",
			neovim = "",
			plugin = "󰒲",
		},
	},
}

local colors = {
	dark = {
		bg = "#1a1b26",
		fg = "#c0caf5",
		mode = {
			normal = { fg = "#1a1b26", bg = "#7aa2f7" },
			insert = { fg = "#1a1b26", bg = "#9ece6a" },
			visual = { fg = "#1a1b26", bg = "#bb9af7" },
			replace = { fg = "#1a1b26", bg = "#f7768e" },
			command = { fg = "#1a1b26", bg = "#e0af68" },
			terminal = { fg = "#1a1b26", bg = "#73daca" },
		},
		git = { fg = "#1a1b26", bg = "#ff9e64" },
		file = { fg = "#1a1b26", bg = "#7dcfff" },
		diag = { fg = "#1a1b26", bg = "#f7768e" },
		info = { fg = "#1a1b26", bg = "#9ece6a" },
	},
	light = {
		bg = "#d5d6db",
		fg = "#343b58",
		mode = {
			normal = { fg = "#ffffff", bg = "#4151b9" },
			insert = { fg = "#ffffff", bg = "#485e30" },
			visual = { fg = "#ffffff", bg = "#8c4351" },
			replace = { fg = "#ffffff", bg = "#8c4351" },
			command = { fg = "#ffffff", bg = "#8f5e15" },
			terminal = { fg = "#ffffff", bg = "#166775" },
		},
		git = { fg = "#ffffff", bg = "#965027" },
		file = { fg = "#ffffff", bg = "#34548a" },
		diag = { fg = "#ffffff", bg = "#8c4351" },
		info = { fg = "#ffffff", bg = "#485e30" },
	},
}

local function get_mode()
	local mode = vim.api.nvim_get_mode().mode
	local mode_map = {
		["n"] = { text = "NORMAL", icon = M.config.icons.mode.normal },
		["i"] = { text = "INSERT", icon = M.config.icons.mode.insert },
		["v"] = { text = "VISUAL", icon = M.config.icons.mode.visual },
		["V"] = { text = "V-LINE", icon = M.config.icons.mode.visual },
		[""] = { text = "V-BLOCK", icon = M.config.icons.mode.visual },
		["c"] = { text = "COMMAND", icon = M.config.icons.mode.command },
		["r"] = { text = "REPLACE", icon = M.config.icons.mode.replace },
		["R"] = { text = "REPLACE", icon = M.config.icons.mode.replace },
		["t"] = { text = "TERMINAL", icon = M.config.icons.mode.terminal },
	}
	local mode_info = mode_map[mode] or { text = "UNKNOWN", icon = "❓" }
	return string.format("%s %s", mode_info.icon, mode_info.text)
end

local function get_git_info()
	local signs
	local ok = pcall(function()
		signs = vim.b.gitsigns_status_dict
	end)

	if not ok or not signs then
		return ""
	end

	local icons = M.config.icons.git
	local added = signs.added and signs.added > 0 and (icons.added .. signs.added .. " ") or ""
	local changed = signs.changed and signs.changed > 0 and (icons.modified .. signs.changed .. " ") or ""
	local removed = signs.removed and signs.removed > 0 and (icons.removed .. signs.removed .. " ") or ""
	local branch = signs.head and (#signs.head > 0) and (icons.branch .. " " .. signs.head) or ""

	return (branch .. " " .. added .. changed .. removed):gsub("^%s*(.-)%s*$", "%1")
end

local function get_file_info()
	local filename = vim.fn.expand("%:t")
	local extension = vim.fn.expand("%:e")
	local icon = M.config.icons.file.default

	local has_devicons, devicons = pcall(require, "nvim-web-devicons")
	if has_devicons then
		local ft_icon = devicons.get_icon(filename, extension)
		if ft_icon then
			icon = ft_icon
		end
	end

	if filename == "" then
		filename = "[No Name]"
	end

	local readonly = vim.bo.readonly and M.config.icons.file.readonly or ""
	local modified = vim.bo.modified and M.config.icons.file.modified or ""

	return string.format("%s %s%s%s", icon, filename, readonly, modified)
end

local function get_lsp_diagnostics()
	local diagnostics = {
		errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
		warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
		info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
		hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
	}

	local icons = M.config.icons.diagnostics
	local parts = {}

	if diagnostics.errors > 0 then
		table.insert(parts, string.format("%s %d", icons.error, diagnostics.errors))
	end
	if diagnostics.warnings > 0 then
		table.insert(parts, string.format("%s %d", icons.warn, diagnostics.warnings))
	end
	if diagnostics.info > 0 then
		table.insert(parts, string.format("%s %d", icons.info, diagnostics.info))
	end
	if diagnostics.hints > 0 then
		table.insert(parts, string.format("%s %d", icons.hint, diagnostics.hints))
	end

	return table.concat(parts, " ")
end

local function get_os_info()
	local icons = M.config.icons.system
	local os = utils.get_os()
	local os_icon = {
		Linux = icons.linux,
		Windows = icons.windows,
		macOS = icons.macos,
	}
	return string.format("%s %s", os_icon[os] or "❓", os)
end

local function get_plugin_count()
	local has_lazy, lazy = pcall(require, "lazy")
	if not has_lazy then
		return ""
	end

	local stats = lazy.stats()
	return string.format("%s %d plugins", M.config.icons.system.plugin, stats.count)
end

local function get_nvim_version()
	local version = vim.version()
	return string.format(
		"%s Neovim v%d.%d.%d",
		M.config.icons.system.neovim,
		version.major,
		version.minor,
		version.patch
	)
end

local function get_datetime()
	return os.date("📅 %a %d %b | 🕒 %H:%M")
end

local function create_separator(style)
	local seps = {
		slant = { left = "", right = "" },
		round = { left = "", right = "" },
		block = { left = "█", right = "█" },
	}
	return seps[style] or seps.slant
end

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

	local theme = M.config.theme == "auto" and (vim.o.background == "dark" and colors.dark or colors.light)
		or colors[M.config.theme]

	local separators = create_separator(M.config.style)

	local function set_highlights()
		local highlights = {
			BismillahLineNormal = string.format(
				"guifg=%s guibg=%s gui=bold",
				theme.mode.normal.fg,
				theme.mode.normal.bg
			),
			BismillahLineInsert = string.format(
				"guifg=%s guibg=%s gui=bold",
				theme.mode.insert.fg,
				theme.mode.insert.bg
			),
			BismillahLineVisual = string.format(
				"guifg=%s guibg=%s gui=bold",
				theme.mode.visual.fg,
				theme.mode.visual.bg
			),
			BismillahLineReplace = string.format(
				"guifg=%s guibg=%s gui=bold",
				theme.mode.replace.fg,
				theme.mode.replace.bg
			),
			BismillahLineCommand = string.format(
				"guifg=%s guibg=%s gui=bold",
				theme.mode.command.fg,
				theme.mode.command.bg
			),
			BismillahLineGit = string.format("guifg=%s guibg=%s gui=bold", theme.git.fg, theme.git.bg),
			BismillahLineFile = string.format("guifg=%s guibg=%s gui=bold", theme.file.fg, theme.file.bg),
			BismillahLineDiag = string.format("guifg=%s guibg=%s gui=bold", theme.diag.fg, theme.diag.bg),
			BismillahLineInfo = string.format("guifg=%s guibg=%s gui=bold", theme.info.fg, theme.info.bg),
		}

		for name, def in pairs(highlights) do
			vim.cmd(string.format("hi %s %s", name, def))
		end
	end

	set_highlights()
end

function M.statusline()
	local mode = get_mode()
	local git_info = M.config.sections.git and get_git_info() or ""
	local file_info = M.config.sections.file and get_file_info() or ""
	local diagnostics = M.config.sections.diagnostics and get_lsp_diagnostics() or ""
	local os_info = M.config.sections.system and get_os_info() or ""
	local plugin_count = M.config.sections.system and get_plugin_count() or ""
	local nvim_version = M.config.sections.system and get_nvim_version() or ""
	local datetime = M.config.sections.datetime and get_datetime() or ""

	local separators = create_separator(M.config.style)

	return table.concat({
		"%#BismillahLineNormal#",
		" ",
		mode,
		" ",
		separators.right,
		git_info ~= "" and ("%#BismillahLineGit# " .. git_info .. " " .. separators.right) or "",
		"%#BismillahLineFile#",
		" ",
		file_info,
		" ",
		separators.right,
		diagnostics ~= "" and ("%#BismillahLineDiag# " .. diagnostics .. " " .. separators.right) or "",
		"%=",
		"%#BismillahLineInfo#",
		separators.left,
		" ",
		os_info,
		" | ",
		plugin_count,
		" | ",
		nvim_version,
		" | ",
		datetime,
		" ",
	})
end

function M.display_quote()
	local quote = quotes.get_random_quote()
	vim.api.nvim_echo({ { quote, "Normal" } }, true, {})
end

function M.init()
	M.setup()
	if vim.g.bismillahline_display_quote_on_start ~= false then
		M.display_quote()
	end
end

return M
