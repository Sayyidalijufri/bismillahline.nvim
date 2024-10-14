local M = {}

function M.get_os()
	if vim.fn.has("win32") == 1 then
		return "Windows"
	elseif vim.fn.has("macunix") == 1 then
		return "macOS"
	else
		return "Linux"
	end
end

return M
