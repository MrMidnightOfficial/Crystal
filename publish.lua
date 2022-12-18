-- Remodel Publish script

--local KNIT_ASSET_ID = "5530714855"

print("Loading Crystal")
local place = remodel.readPlaceFile("Crystal.rbxl")
local Packages = place.ReplicatedStorage.Packages
Packages.Crystal.Packages:Destroy()

print("Writing Crystal module to model file...")
remodel.writeModelFile(Packages, "Crystal.rbxm")
print("Crystal model written")

--print("Publishing Knit module to Roblox...")
--remodel.writeExistingModelAsset(Packages, KNIT_ASSET_ID)
--print("Knit asset published")
