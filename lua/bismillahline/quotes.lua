local M = {}

local quotes = {
	-- Quran verses with Arabic
	{
		arabic = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
		translation = '"In the name of Allah, the Most Gracious, the Most Merciful" - Al-Fatihah 1:1',
	},
	{
		arabic = "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ",
		translation = '"And when My servants ask you concerning Me, indeed I am near." - Al-Baqarah 2:186',
	},
	{
		arabic = "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
		translation = '"For indeed, with hardship [will be] ease." - Ash-Sharh 94:5',
	},
	-- Add more quotes here
}

function M.get_random_quote()
	math.randomseed(os.time())
	local quote = quotes[math.random(#quotes)]
	return string.format("%s\n%s", quote.arabic, quote.translation)
end

return M
