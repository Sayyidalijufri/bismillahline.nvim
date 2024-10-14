local M = {}

local quotes = {
	-- Hadiths
	'"The strong believer is better and more beloved to Allah than the weak believer, while there is good in both." - Prophet Muhammad (PBUH)',
	'"The best among you are those who have the best manners and character." - Prophet Muhammad (PBUH)',
	'"None of you [truly] believes until he loves for his brother what he loves for himself." - Prophet Muhammad (PBUH)',

	-- Quran verses
	'"And when My servants ask you concerning Me, indeed I am near." - Quran 2:186',
	'"For indeed, with hardship [will be] ease." - Quran 94:5',
	'"And Allah is the best of providers." - Quran 62:11',
}

function M.get_random_quote()
	math.randomseed(os.time())
	return quotes[math.random(#quotes)]
end

return M
