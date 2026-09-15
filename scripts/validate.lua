--!strict
-- Validation script for Villains Evolved balance and publish guardrails
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local isPublish = os.getenv("PUBLISH") == "1" or os.getenv("PUBLISH") == "true"

print("--- Running Villains Evolved Validation ---")
print("Mode: " .. (isPublish and "PUBLISH (Strict)" or "DEVELOPMENT"))

-- 1. Check unique villain IDs and sourceRef rules
local villainIds: { [string]: boolean } = {}
for _, v in Config.Villains do
	assert(v.id ~= nil and v.id ~= "", "Villain missing id: " .. tostring(v.name))
	assert(not villainIds[v.id], "Duplicate villain id detected: " .. v.id)
	villainIds[v.id] = true

	if isPublish then
		assert(v.sourceRef == nil, "PUBLISH check failed: placeholder sourceRef found on villain " .. v.id)
	end
end
print(string.format("✓ %d villains validated uniquely.", #Config.Villains))

-- 2. Check Jobs requiredInfamy is strictly increasing per district
for districtId, jobs in Config.Jobs do
	local lastInfamy = -1
	for jobIndex, job in jobs do
		assert(
			job.requiredInfamy > lastInfamy,
			string.format("District %d Job %d requiredInfamy (%d) is not > previous (%d)", districtId, jobIndex, job.requiredInfamy, lastInfamy)
		)
		lastInfamy = job.requiredInfamy
	end
end
print("✓ All district jobs strictly increase in requiredInfamy.")

-- 3. Check crate weights
for _, crate in Config.Crates do
	local sum = 0
	for _, weight in crate.weights do
		sum += weight
	end
	assert(math.abs(sum - 100) < 0.01 or math.abs(sum - 1.0) < 0.001, "Crate " .. crate.id .. " weights do not sum to 100 or 1. Sum: " .. tostring(sum))
end
print(string.format("✓ %d crates validated with correct odds.", #Config.Crates))

print("--- All Validations Passed Successfully ---")
return true
