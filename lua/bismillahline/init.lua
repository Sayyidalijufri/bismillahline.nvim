local M = {}
local utils = require("bismillahline.utils")
local quotes = require("bismillahline.quotes")

-- Simple default config
M.config = {
    icons = {
        normal = "N",
        insert = "I",
        visual = "V",
        command = "C",
        replace = "R",
        terminal = "T",
    },
    colors = {
        bg = "#1a1b26",
        fg = "#c0caf5",
        normal = "#7aa2f7",
        insert = "#9ece6a",
        visual = "#bb9af7",
        replace = "#f7768e",
        command = "#e0af68",
    },
    enable_git = true,
    enable_quote = true,
}

-- Safe mode detection
local function get_mode()
    local mode_map = {
        ["n"] = "NORMAL",
        ["i"] = "INSERT",
        ["v"] = "VISUAL",
        ["V"] = "V-LINE",
        [""] = "V-BLOCK",
        ["c"] = "COMMAND",
        ["r"] = "REPLACE",
        ["R"] = "REPLACE",
        ["t"] = "TERMINAL",
    }
    
    local ok, mode = pcall(vim.api.nvim_get_mode)
    if not ok then return "NORMAL" end
    return mode_map[mode.mode] or "NORMAL"
end

-- Safe git information retrieval
local function get_git_info()
    if not M.config.enable_git then return "" end
    
    local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    if branch == "" then return "" end
    
    local status = vim.fn.system("git status --porcelain 2> /dev/null")
    local added, modified, deleted = 0, 0, 0
    
    for line in status:gmatch("[^\r\n]+") do
        if line:match("^A") then added = added + 1
        elseif line:match("^M") then modified = modified + 1
        elseif line:match("^D") then deleted = deleted + 1
        end
    end
    
    return string.format("🌿 %s | +%d ~%d -%d", branch, added, modified, deleted)
end

-- Safe file information
local function get_file_info()
    local icon = "📄"
    local filename = vim.fn.expand("%:t")
    if filename == "" then
        filename = "[No Name]"
    end
    local readonly = vim.bo.readonly and "🔒" or ""
    local modified = vim.bo.modified and "📝" or ""
    return string.format("%s %s%s%s", icon, filename, readonly, modified)
end

-- Safe diagnostics information
local function get_diagnostics()
    local diagnostics = ""
    local ok, diagnostic_module = pcall(vim.diagnostic, "get")
    
    if ok then
        local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        if errors > 0 then diagnostics = diagnostics .. "❌" .. errors .. " " end
        if warnings > 0 then diagnostics = diagnostics .. "⚠️" .. warnings end
    end
    
    return diagnostics
end

-- Safe statusline generation
function M.statusline()
    local mode = get_mode()
    local git = get_git_info()
    local file = get_file_info()
    local diag = get_diagnostics()
    
    local status = {
        "%#StatusLine#",
        "▎" .. mode .. "▎",
        git ~= "" and "[ " .. git .. " ]" or "",
        file,
        "%=", -- right align
        diag,
        " %l:%c ", -- line and column
        os.date("%H:%M"),
    }
    
    return table.concat(status)
end

-- Safe quote display
function M.display_quote()
    if not M.config.enable_quote then return end
    
    local ok, quote = pcall(quotes.get_random_quote)
    if ok then
        vim.notify(quote, vim.log.levels.INFO)
    end
end

-- Safe setup function
function M.setup(opts)
    -- Safely merge user config
    if opts then
        M.config = vim.tbl_deep_extend("force", M.config, opts)
    end
    
    -- Set up basic highlight groups
    local highlights = {
        "hi BismillahLineNormal guibg=#65D1FF guifg=#000000",
        "hi BismillahLineNC guibg=#112638 guifg=#c3ccdc",
        "hi BismillahLineGit guibg=#FF61EF guifg=#000000",
        "hi BismillahLineFile guibg=#3EFFDC guifg=#000000",
    }
    
    for _, hl in ipairs(highlights) do
        pcall(vim.cmd, hl)
    end
    
    -- Set statusline
    vim.o.statusline = [[%!luaeval("require'bismillahline'.statusline()")]]
    
    -- Display initial quote
    if M.config.enable_quote then
        vim.defer_fn(function()
            M.display_quote()
        end, 100)
    end
end

-- Safe initialization
function M.init()
    pcall(M.setup)
end

return M
local M = {}
local utils = require("bismillahline.utils")
local quotes = require("bismillahline.quotes")

-- Simple default config
M.config = {
    icons = {
        normal = "N",
        insert = "I",
        visual = "V",
        command = "C",
        replace = "R",
        terminal = "T",
    },
    colors = {
        bg = "#1a1b26",
        fg = "#c0caf5",
        normal = "#7aa2f7",
        insert = "#9ece6a",
        visual = "#bb9af7",
        replace = "#f7768e",
        command = "#e0af68",
    },
    enable_git = true,
    enable_quote = true,
}

-- Safe mode detection
local function get_mode()
    local mode_map = {
        ["n"] = "NORMAL",
        ["i"] = "INSERT",
        ["v"] = "VISUAL",
        ["V"] = "V-LINE",
        [""] = "V-BLOCK",
        ["c"] = "COMMAND",
        ["r"] = "REPLACE",
        ["R"] = "REPLACE",
        ["t"] = "TERMINAL",
    }
    
    local ok, mode = pcall(vim.api.nvim_get_mode)
    if not ok then return "NORMAL" end
    return mode_map[mode.mode] or "NORMAL"
end

-- Safe git information retrieval
local function get_git_info()
    if not M.config.enable_git then return "" end
    
    local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    if branch == "" then return "" end
    
    local status = vim.fn.system("git status --porcelain 2> /dev/null")
    local added, modified, deleted = 0, 0, 0
    
    for line in status:gmatch("[^\r\n]+") do
        if line:match("^A") then added = added + 1
        elseif line:match("^M") then modified = modified + 1
        elseif line:match("^D") then deleted = deleted + 1
        end
    end
    
    return string.format("🌿 %s | +%d ~%d -%d", branch, added, modified, deleted)
end

-- Safe file information
local function get_file_info()
    local icon = "📄"
    local filename = vim.fn.expand("%:t")
    if filename == "" then
        filename = "[No Name]"
    end
    local readonly = vim.bo.readonly and "🔒" or ""
    local modified = vim.bo.modified and "📝" or ""
    return string.format("%s %s%s%s", icon, filename, readonly, modified)
end

-- Safe diagnostics information
local function get_diagnostics()
    local diagnostics = ""
    local ok, diagnostic_module = pcall(vim.diagnostic, "get")
    
    if ok then
        local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        if errors > 0 then diagnostics = diagnostics .. "❌" .. errors .. " " end
        if warnings > 0 then diagnostics = diagnostics .. "⚠️" .. warnings end
    end
    
    return diagnostics
end

-- Safe statusline generation
function M.statusline()
    local mode = get_mode()
    local git = get_git_info()
    local file = get_file_info()
    local diag = get_diagnostics()
    
    local status = {
        "%#StatusLine#",
        "▎" .. mode .. "▎",
        git ~= "" and "[ " .. git .. " ]" or "",
        file,
        "%=", -- right align
        diag,
        " %l:%c ", -- line and column
        os.date("%H:%M"),
    }
    
    return table.concat(status)
end

-- Safe quote display
function M.display_quote()
    if not M.config.enable_quote then return end
    
    local ok, quote = pcall(quotes.get_random_quote)
    if ok then
        vim.notify(quote, vim.log.levels.INFO)
    end
end

-- Safe setup function
function M.setup(opts)
    -- Safely merge user config
    if opts then
        M.config = vim.tbl_deep_extend("force", M.config, opts)
    end
    
    -- Set up basic highlight groups
    local highlights = {
        "hi BismillahLineNormal guibg=#65D1FF guifg=#000000",
        "hi BismillahLineNC guibg=#112638 guifg=#c3ccdc",
        "hi BismillahLineGit guibg=#FF61EF guifg=#000000",
        "hi BismillahLineFile guibg=#3EFFDC guifg=#000000",
    }
    
    for _, hl in ipairs(highlights) do
        pcall(vim.cmd, hl)
    end
    
    -- Set statusline
    vim.o.statusline = [[%!luaeval("require'bismillahline'.statusline()")]]
    
    -- Display initial quote
    if M.config.enable_quote then
        vim.defer_fn(function()
            M.display_quote()
        end, 100)
    end
end

-- Safe initialization
function M.init()
    pcall(M.setup)
end

return M
