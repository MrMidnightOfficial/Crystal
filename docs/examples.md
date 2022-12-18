---
sidebar_position: 7
---

# Examples

## Start All Services

A useful pattern is to keep all service modules within a folder. The script that starts Knit can then require all of these at once. Let's say we have a directory structure like such:

- Server
	- CrystalRuntime [Script]
	- Services [Folder]
		- MyService [Module]
		- AnotherService [Module]
		- HelloService [Module]

We can write our CrystalRuntime script as such:

```lua
local Crystal = require(game:GetService("ReplicatedStorage").Packages.Crystal)

-- Load all services:
for _,v in ipairs(script.Parent.Services:GetDescendants()) do
	if (v:IsA("ModuleScript")) then
		require(v)
	end
end

Crystal.Start():catch(warn)
```

Alternatively, we can use `Crystal.AddServices` or `Crystal.AddServicesDeep` to load all of the services without writing a loop. It scans and loads all ModuleScripts found and passes them to `Crystal.CreateService`:

```lua
local Crystal = require(game:GetService("ReplicatedStorage").Packages.Crystal)

-- Load all services within 'Services':
Crystal.AddServices(script.Parent.Services)

-- Load all services (the Deep version scans all descendants of the passed instance):
Crystal.AddServicesDeep(script.Parent.OtherServices)

Crystal.Start():catch(warn)
```

:::tip
This same design practice can also be done on the client with controllers. Either loop through and collect controllers or use the `Crystal.AddControllers` or `Crystal.AddControllersDeep` function.
:::

----------------

## Expose a Collection of Modules

Like `Crystal.Util`, we can expose a collection of modules to our codebase. This is very simple. All we need to do is add `Crystal.WHATEVER` and point it to a folder of ModuleScripts.

For instance, if we had a folder of modules at `ReplicatedStorage.MyModules`, we can expose this within our main runtime script:

```lua
local Crystal = require(game:GetService("ReplicatedStorage").Packages.Crystal)

-- Expose our MyModules folder:
Crystal.MyModules = game:GetService("ReplicatedStorage").MyModules

-- Load services/controllers

Crystal.Start()
```

We can then use these modules elsewhere. For instance:

```lua
local SomeModule = require(Crystal.MyModules.SomeModule)
```
