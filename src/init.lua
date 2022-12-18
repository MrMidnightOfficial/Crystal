if game:GetService("RunService"):IsServer() then
	return require(script.CrystalServer)
else
	local CrystalServer = script:FindFirstChild("CrystalServer")
	if CrystalServer then
		CrystalServer:Destroy()
	end
	return require(script.CrystalClient)
end
