--!strict
local Format = {}

local SUFFIXES: { string } = {
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"
}

function Format.abbreviate(n: number): string
	if n < 0 then
		return "-" .. Format.abbreviate(-n)
	end
	if n < 1000 then
		return string.format("%d", math.floor(n))
	end

	local exp = math.floor(math.log10(n) / 3)
	local index = exp + 1
	if index > #SUFFIXES then
		index = #SUFFIXES
	end

	local suffix = SUFFIXES[index]
	local value = n / (10 ^ (3 * (index - 1)))

	if value >= 100 then
		return string.format("%d%s", math.floor(value), suffix)
	elseif value >= 10 then
		return string.format("%.1f%s", value, suffix)
	else
		return string.format("%.2f%s", value, suffix)
	end
end

function Format.timer(totalSeconds: number): string
	if totalSeconds < 0 then
		totalSeconds = 0
	end
	local minutes = math.floor(totalSeconds / 60)
	local seconds = math.floor(totalSeconds % 60)
	return string.format("%02d:%02d", minutes, seconds)
end

function Format.comma(n: number): string
	local formatted = tostring(math.floor(n))
	local k: number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

return Format
