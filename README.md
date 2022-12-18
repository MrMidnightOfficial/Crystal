![Release]https://github.com/AnimalStudio-Official/Crystal/workflows/Release/badge.svg)
![Lint](https://github.com/AnimalStudio-Official/Crystal/workflows/Lint/badge.svg)
![Deploy Docs](https://github.com/AnimalStudio-Official/Crystal/workflows/Deploy%20Docs/badge.svg)


#Crystal

Crystal is a lightweight framework for Roblox that simplifies communication between core parts of your game and seamlessly bridges the gap between the server and the client.


## Install

Installing Crystal is very simple. Just drop the module into ReplicatedStorage.
**Roblox Studio workflow:**

1. Get Crystal from the Release.
1. Place Crystal directly within ReplicatedStorage.

## Basic Usage

The core usage of Crystal is the same from the server and the client. The general pattern is to create a single script on the server and a single script on the client. These scripts will load Crystal, create services/controllers, and then start Crystal.

The most basic usage would look as such:

```lua
local Crystal = require(game:GetService("ReplicatedStorage").Packages.Crystal)

Crystal.Start():catch(warn)
-- Crystal.Start() returns a Promise, so we are catching any errors and feeding it to the built-in 'warn' function
-- You could also chain 'await()' to the end to yield until the whole sequence is completed:
--    Crystal.Start():catch(warn):await()
```

That would be the necessary code on both the server and the client. However, nothing interesting is going to happen. Let's dive into some more examples.

### A Simple Service

A service is simply a structure that _serves_ some specific purpose. For instance, a game might have a MoneyService, which manages in-game currency for players. Let's look at a simple example:

```lua
local Crystal = require(game:GetService("ReplicatedStorage").Packages.Crystal)

-- Create the service:
local MoneyService = Crystal.CreateService {
	Name = "MoneyService",
}

-- Add some methods to the service:

function MoneyService:GetMoney(player)
	-- Do some sort of data fetch
	local money = someDataStore:GetAsync("money")
	return money
end

function MoneyService:GiveMoney(player, amount)
	-- Do some sort of data fetch
	local money = self:GetMoney(player)
	money += amount
	someDataStore:SetAsync("money", money)
end

Crystal.Start():catch(warn)
```

Now we have a little MoneyService that can get and give money to a player. However, only the server can use this at the moment. What if we want clients to fetch how much money they have? To do this, we have to create some client-side code to consume our service. We _could_ create a controller, but it's not necessary for this example.

First, we need to expose a method to the client. We can do this by writing methods on the service's Client table:

```lua
-- Money service on the server
...
function MoneyService.Client:GetMoney(player)
	-- We already wrote this method, so we can just call the other one.
	-- 'self.Server' will reference back to the root MoneyService.
	return self.Server:GetMoney(player)
end
...
```

We can write client-side code to fetch money from the service:

```lua
-- Client-side code
local Crystal = require(game:GetService("ReplicatedStorage").Packages.Crystal)
Crystal.Start():catch(warn):await()

local MoneyService = Crystal.GetService("MoneyService")

MoneyService:GetMoney():andThen(function(money)
	print(money)
end)
```

Under the hood, Crystal is creating a RemoteFunction bound to the service's GetMoney method. Crystal keeps RemoteFunctions and RemoteEvents out of the way so that developers can focus on writing code and not building networking infrastructure.
