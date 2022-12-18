---
sidebar_position: 5
---

# Util

## Crystal via ModuleScript
Crystal comes with a few utility modules. If Crystal is being used from the packaged
ModuleScript, then the best way to access these modules is via `require(Crystal.Util.PACKAGE)`.

The following modules are available:

- [`Crystal.Util.Comm`](https://sleitnick.github.io/RbxUtil/api/Comm)
- [`Crystal.Util.Component`](https://sleitnick.github.io/RbxUtil/api/Component)
- [`Crystal.Util.EnumList`](https://sleitnick.github.io/RbxUtil/api/EnumList)
- [`Crystal.Util.Input`](https://sleitnick.github.io/RbxUtil/api/Input)
- [`Crystal.Util.Option`](https://sleitnick.github.io/RbxUtil/api/Option)
- [`Crystal.Util.Signal`](https://sleitnick.github.io/RbxUtil/api/Signal)
- [`Crystal.Util.Streamable`](https://sleitnick.github.io/RbxUtil/api/Streamable)
- [`Crystal.Util.TableUtil`](https://sleitnick.github.io/RbxUtil/api/TableUtil)
- [`Crystal.Util.Timer`](https://sleitnick.github.io/RbxUtil/api/Timer)
- [`Crystal.Util.Trove`](https://sleitnick.github.io/RbxUtil/api/Trove)
- [`Crystal.Util.Promise`](https://eryn.io/roblox-lua-promise/api/Promise)

Below is an example of the Signal class being used in a service:

```lua
local Signal = require(Crystal.Util.Signal)

local MyService = Crystal.CreateService {
	Name = "MyService",
	SomeSignal = Signal.new(),
}
```
