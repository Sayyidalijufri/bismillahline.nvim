local M = {}
local utils = require("bismillahline.utils")
local quotes = require("bismillahline.quotes")

local function get_mode()
    local mode_map = {
        ["n"] = "🔵 NORMAL",
        ["i"] = "🔹 INSERT",
        ["v"] = "🔺 VISUAL",
        ["V"] = "🔻 V-LINE",
        [""] = "🔼 V-BLOCK",
        ["c"] = "🔄 COMMAND",
        ["r"] = "🔄 REPLACE",
        ["R"] = "🔄 REPLACE",
        ["t"] = "🔄 TERMINAL",
    }
    return mode_map[vim.api.nvim_get_mode().mode] or "🔮 UNKNOWN"
end

local function get_git_info()
    local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    if branch ~= "" then
        local status = vim.fn.system("git status --porcelain 2> /dev/null")
        local added, modified, deleted = 0, 0, 0
        for line in status:gmatch("[^\r\n]+") do
            if line:match("^A") then
                added = added + 1
            elseif line:match("^M") then
                modified = modified + 1
            elseif line:match("^D") then
                deleted = deleted + 1
            end
        end
        return string.format("🌿 %s | +%d ~%d -%d", branch, added, modified, deleted)
    else
        return ""
    end
end

local function get_file_info()
    local icon = "📎"
    local filename = vim.fn.expand("%:t")
    if filename == "" then
        filename = "[No Name]"
    end
    local readonly = vim.bo.readonly and "🔒" or ""
    local modified = vim.bo.modified and "🔄" or ""
    return string.format("%s %s%s%s", icon, filename, readonly, modified)
end

local function get_lsp_diagnostics()
    local counts = { 0, 0, 0, 0 }
    local levels = { "Error", "Warn", "Info", "Hint" }
    local icons = { "🚨", "⚠️", "🔍", "💡" }
    for i, level in ipairs(levels) do
        counts[i] = #vim.diagnostic.get(0, { severity = level })
    end
    local result = {}
    for i, count in ipairs(counts) do
        if count > 0 then
            table.insert(result, string.format("%s%d", icons[i], count))
        end
    end
    return table.concat(result, " ")
end

local function get_os_info()
    local os = utils.get_os()
    local os_icon = {
        Linux = "🐧",
        Windows = "🪟",
        macOS = "🍏",
    }
    return string.format("%s %s", os_icon[os] or "🤔", os)
end

local function get_plugin_count()
    local stats = require("lazy").stats()
    return string.format("🧩 %d plugins", stats.count)
end

local function get_nvim_version()
    local version = vim.version()
    return string.format("💻 Neovim v%d.%d.%d", version.major, version.minor, version.patch)
end

local function get_datetime()
    return os.date("🕰️ %a %d %b | 🕒 %H:%M")
end

function M.setup()
    -- Set up highlight groups
    vim.cmd([[
        hi BismillahLineNormal guibg=#4B7287 guifg=#FFFFFF
        hi BismillahLineNC guibg=#2B3A42 guifg=#A9B665
        hi BismillahLineGit guibg=#FFA07A guifg=#000000
        hi BismillahLineFile guibg=#3E8E41 guifg=#FFFFFF
        hi BismillahLineDiag guibg=#FFD700 guifg=#000000
        hi BismillahLineInfo guibg=#FF6347 guifg=#FFFFFF
    ]])

    -- Set statusline
    vim.o.statusline = [[%!luaeval("require'bismillahline'.statusline()")]]
end

function M.statusline()
    local mode = get_mode()
    local git_info = get_git_info()
    local file_info = get_file_info()
    local diagnostics = get_lsp_diagnostics()
    local os_info = get_os_info()
    local plugin_count = get_plugin_count()
    local nvim_version = get_nvim_version()
    local datetime = get_datetime()

    return table.concat({
        "%#BismillahLineNormal#",
        "╔═ " .. mode .. " ",
        "%#BismillahLineGit#",
        git_info ~= "" and ("═ " .. git_info .. " ") or "",
        "%#BismillahLineFile#",
        "═ " .. file_info .. " ",
        "%#BismillahLineDiag#",
        diagnostics ~= "" and ("═ " .. diagnostics .. " ") or "",
        "%=", -- Right align
        "%#BismillahLineInfo#",
        "═ " .. os_info .. " ═ ",
        plugin_count .. " ═ ",
        nvim_version .. " ═ ",
        datetime .. " ═╗",
    })
end

function M.display_quote()
    local quote = quotes.get_random_quote()
    print(quote)
end

function M.init()
    M.setup()
    M.display_quote()
end

return M
