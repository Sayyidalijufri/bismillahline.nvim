-- init.lua
local M = {}
local utils = require("bismillahline.utils")
local quotes = require("bismillahline.quotes")

-- Style presets
M.styles = {
    minimal = {
        separator_left = "",
        separator_right = "",
        subseparator_left = "│",
        subseparator_right = "│",
        prefix = " ",
        suffix = " ",
    },
    slanted = {
        separator_left = "",
        separator_right = "",
        subseparator_left = "",
        subseparator_right = "",
        prefix = " ",
        suffix = " ",
    },
    rounded = {
        separator_left = "",
        separator_right = "",
        subseparator_left = "",
        subseparator_right = "",
        prefix = " ",
        suffix = " ",
    },
    powerline = {
        separator_left = "",
        separator_right = "",
        subseparator_left = "",
        subseparator_right = "",
        prefix = "",
        suffix = "",
    },
    bubbles = {
        separator_left = "",
        separator_right = "",
        subseparator_left = "•",
        subseparator_right = "•",
        prefix = " ",
        suffix = " ",
    },
}

-- Modern color schemes
M.themes = {
    tokyonight = {
        bg = "#1a1b26",
        fg = "#c0caf5",
        normal = "#7aa2f7",
        insert = "#9ece6a",
        visual = "#bb9af7",
        replace = "#f7768e",
        command = "#e0af68",
        inactive = "#565f89",
        git_add = "#9ece6a",
        git_change = "#e0af68",
        git_delete = "#f7768e",
        diagnostics_error = "#db4b4b",
        diagnostics_warn = "#e0af68",
        diagnostics_info = "#0db9d7",
        diagnostics_hint = "#1abc9c",
    },
    catppuccin = {
        bg = "#1e1e2e",
        fg = "#cdd6f4",
        normal = "#89b4fa",
        insert = "#a6e3a1",
        visual = "#f5c2e7",
        replace = "#f38ba8",
        command = "#fab387",
        inactive = "#6c7086",
        git_add = "#a6e3a1",
        git_change = "#fab387",
        git_delete = "#f38ba8",
        diagnostics_error = "#f38ba8",
        diagnostics_warn = "#fab387",
        diagnostics_info = "#89b4fa",
        diagnostics_hint = "#94e2d5",
    },
    nord = {
        bg = "#2e3440",
        fg = "#eceff4",
        normal = "#88c0d0",
        insert = "#a3be8c",
        visual = "#b48ead",
        replace = "#bf616a",
        command = "#ebcb8b",
        inactive = "#4c566a",
        git_add = "#a3be8c",
        git_change = "#ebcb8b",
        git_delete = "#bf616a",
        diagnostics_error = "#bf616a",
        diagnostics_warn = "#ebcb8b",
        diagnostics_info = "#88c0d0",
        diagnostics_hint = "#8fbcbb",
    },
}

-- Default configuration
M.config = {
    theme = "tokyonight",
    style = "slanted",
    icons = {
        -- Session icons
        session = "󰆓",
        session_load = "",
        session_save = "",
        
        -- Git icons
        git_branch = "",
        git_add = "",
        git_mod = "",
        git_remove = "",
        git_dirty = "",
        git_clean = "",
        git_stash = "󰆓",
        
        -- File icons
        file_readonly = "",
        file_modified = "",
        file_new = "",
        file_locked = "",
        
        -- Mode icons with Nerd Font support
        normal = "",
        insert = "",
        visual = "",
        visual_block = "",
        command = "",
        terminal = "",
        replace = "",
        
        -- LSP and diagnostics
        lsp_active = "",
        error = "",
        warning = "",
        info = "",
        hint = "",
        
        -- System
        os_linux = "",
        os_mac = "",
        os_windows = "",
        
        -- Additional features
        prayer = "󰍉",
        quran = "",
        tasbih = "󰫫",
        clock = "",
        calendar = "",
        memory = "󰍛",
        cpu = "",
    },
    components = {
        session = true,
        git = true,
        diagnostics = true,
        lsp = true,
        prayer_times = true,
        system_info = true,
    },
    prayer_times_location = {
        latitude = 0,
        longitude = 0,
        method = "ISNA",  -- Prayer calculation method
    },
}

-- Cached data
local cache = {
    git_status = { data = "", timestamp = 0 },
    prayer_times = { data = {}, timestamp = 0 },
    memory_usage = { data = "", timestamp = 0 },
}

-- Helper function to create component with proper styling
local function create_component(highlight, content, no_separator)
    local style = M.styles[M.config.style]
    local theme = M.themes[M.config.theme]
    
    if not content or content == "" then return "" end
    
    local result = string.format("%%#%s#%s%s%s", 
        highlight,
        style.prefix,
        content,
        style.suffix
    )
    
    if not no_separator then
        result = result .. string.format("%%#%s_Sep#%s", highlight, style.separator_right)
    end
    
    return result
end

-- Mode component with dynamic colors
local function get_mode_component()
    local mode_map = {
        ['n']  = {'NORMAL', 'Normal'},
        ['i']  = {'INSERT', 'Insert'},
        ['v']  = {'VISUAL', 'Visual'},
        ['V']  = {'V-LINE', 'Visual'},
        ['^V'] = {'V-BLOCK', 'Visual'},
        ['c']  = {'COMMAND', 'Command'},
        ['r']  = {'REPLACE', 'Replace'},
        ['R']  = {'REPLACE', 'Replace'},
        ['t']  = {'TERMINAL', 'Terminal'},
    }
    
    local mode = vim.api.nvim_get_mode().mode
    local mode_data = mode_map[mode] or {'UNKNOWN', 'Normal'}
    
    return create_component(
        mode_data[2],
        string.format("%s %s", M.config.icons[mode_data[2]:lower()], mode_data[1])
    )
end

-- Session component
local function get_session_component()
    if not M.config.components.session then return "" end
    
    local session_name = vim.v.this_session ~= "" 
        and vim.fn.fnamemodify(vim.v.this_session, ':t:r')
        or "No Session"
    
    return create_component(
        'Session',
        string.format("%s %s", M.config.icons.session, session_name)
    )
end

-- Enhanced git component with more details
local function get_git_component()
    if not M.config.components.git then return "" end
    
    -- Check cache
    local current_time = os.time()
    if current_time - cache.git_status.timestamp < 2 then
        return cache.git_status.data
    end
    
    local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ';')
    if git_dir == "" then return "" end
    
    local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    if branch == "" then return "" end
    
    local status = vim.fn.system("git status --porcelain 2> /dev/null")
    local added, modified, deleted, stashed = 0, 0, 0, 0
    
    -- Count stashed changes
    local stash_count = vim.fn.system("git stash list | wc -l")
    stashed = tonumber(stash_count) or 0
    
    for line in status:gmatch("[^\r\n]+") do
        if line:match("^A") then added = added + 1
        elseif line:match("^M") then modified = modified + 1
        elseif line:match("^D") then deleted = deleted + 1
        end
    end
    
    local git_info = string.format("%s %s %s%d %s%d %s%d",
        M.config.icons.git_branch, branch,
        M.config.icons.git_add, added,
        M.config.icons.git_mod, modified,
        M.config.icons.git_remove, deleted
    )
    
    if stashed > 0 then
        git_info = git_info .. string.format(" %s%d", M.config.icons.git_stash, stashed)
    end
    
    cache.git_status.data = create_component('Git', git_info)
    cache.git_status.timestamp = current_time
    
    return cache.git_status.data
end

-- Prayer times component
local function get_prayer_times_component()
    if not M.config.components.prayer_times then return "" end
    
    -- Implementation for prayer times calculation would go here
    -- You would need to use a prayer times calculation library
    -- For now, we'll return a placeholder
    return create_component(
        'Prayer',
        string.format("%s Next: Asr 15:30", M.config.icons.prayer)
    )
end

-- System info component
local function get_system_info()
    if not M.config.components.system_info then return "" end
    
    local memory = vim.fn.system("free -h | awk '/^Mem:/ {print $3}'"):gsub("%s+", "")
    local cpu = vim.fn.system("top -bn1 | grep 'Cpu(s)' | awk '{print $2}'"):gsub("%s+", "")
    
    return create_component(
        'SystemInfo',
        string.format("%s %s %s %s%%", 
            M.config.icons.memory, memory,
            M.config.icons.cpu, cpu
        )
    )
end

-- Main statusline function
function M.get_statusline()
    local components = {
        get_mode_component(),
        get_session_component(),
        get_git_component(),
        "%=", -- Left/right separator
        get_prayer_times_component(),
        get_system_info(),
    }
    
    return table.concat(components, "")
end

-- Setup function
function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
    
    -- Set up highlight groups based on theme
    M.setup_highlights()
    
    -- Set statusline
    vim.o.statusline = "%!luaeval('require\"bismillahline\".get_statusline()')"
    
    -- Set up autocommands
    vim.api.nvim_create_autocmd({"WinEnter", "BufEnter", "ModeChanged"}, {
        callback = function() vim.cmd("redrawstatus") end,
    })
end

-- Highlight setup function
function M.setup_highlights()
    local theme = M.themes[M.config.theme]
    local groups = {
        Normal = { fg = theme.fg, bg = theme.normal },
        Insert = { fg = theme.fg, bg = theme.insert },
        Visual = { fg = theme.fg, bg = theme.visual },
        Replace = { fg = theme.fg, bg = theme.replace },
        Command = { fg = theme.fg, bg = theme.command },
        Inactive = { fg = theme.fg, bg = theme.inactive },
        Git = { fg = theme.bg, bg = theme.git_add },
        Session = { fg = theme.bg, bg = theme.normal },
        Prayer = { fg = theme.bg, bg = theme.command },
        SystemInfo = { fg = theme.bg, bg = theme.insert },
    }
    
    for name, colors in pairs(groups) do
        vim.api.nvim_set_hl(0, name, colors)
        vim.api.nvim_set_hl(0, name .. "_Sep", {
            fg = colors.bg,
            bg = theme.bg,
        })
    end
end

return M
