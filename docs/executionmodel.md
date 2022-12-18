---
sidebar_position: 6
---

# Execution Model

## Lifecycle

The execution model of Crystal defines the flow of operations and lifecycle of Crystal.

1. Require the Crystal module
1. Create services or controllers
1. Call `Crystal.Start()`, which immediately returns a Promise
	1. All `CrystalInit` methods are invoked at the same time, and waits for all to finish
	1. All `CrystalStart` methods are invoked at the same time
1. After all `CrystalStart` methods are called, the promise returned by `Crystal.Start()` resolves

![Lifecycle](/lifecycle.svg)

On the server, you should have one Script in ServerScriptService. On the client, you should have one LocalScript in PlayerStarterScripts. Each of these scripts should have a similar layout:

```lua
local Crystal = require(game:GetService("ReplicatedStorage").Packages.Crystal)

-- Load services or controllers here

Crystal.Start():catch(warn)
```

Once services or controllers are created, they persist forever (until the server shuts down or the player leaves).

:::caution
Services and controllers **_cannot_** be created after `Crystal.Start()` has been called.
:::

## Catching CrystalInit Errors
Due to the way Promises work, errors that occur within `CrystalInit` methods of services or controllers will be caught as a rejected promise. These can be handled by either grabbing the status after using `Await` or using the `Catch()` method:

```lua
local success, err = Crystal.Start():await()
if (not success) then
	-- Handle error
	error(tostring(err))
end
```

```lua
Crystal.Start():catch(function(err)
	-- Handle error
	warn(tostring(err))
end)
```

## Best Practices
- Only one Script on the server should manage loading services and starting Crystal
- Only one LocalScript on the client should manage loading controllers and starting Crystal
- Split up services and controllers into their own modules
- Services should be kept in either ServerStorage or ServerScriptService to avoid being exposed to the client
- Code within `CrystalInit` and within the root scope of the ModuleScript should try to finish ASAP, and should avoid yielding if possible
- Events and methods should never be added to a service's Client table after `Crystal.Start()` has been called
- As shown above in the [Catching CrystalInit Errors](#catching-Crystalinit-errors) section, handling a failure case of `Start` is the cleanest way to catch errors on startup.
