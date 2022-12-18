---
sidebar_position: 9
---

# VS Code Snippets

Being able to quickly create services, controllers, or other Crystal-related items is very useful when using Crystal as a framework. To keep Crystal lightweight, there are no required extensions or plugins. Instead, below are some VS Code snippets that can be used to speed up development.

![Snippets](/snippets.gif)

## Using Snippets
Snippets are a Visual Studio Code feature. Check out the [Snippets documentation](https://code.visualstudio.com/docs/editor/userdefinedsnippets) for more info. Adding Snippets for Lua is very easy.

1. Within Visual Studio, navigate from the toolbar: `File -> Preferences -> User Snippets`
1. Type in and select `lua.json`
1. Within the `{}` braces, include any or all of the snippets below
1. Save the file
1. Within your actual source files, start typing a prefix (e.g. "Crystal") and select the autocompleted snippet to paste it in
1. Depending on the snippet, parts of the pasted code will be selected and can be typed over (e.g. setting the name of a service)

-------------------------------------

## Crystal Snippets

Below are useful VS Code snippets for Crystal. The snippets assume that the Crystal module has been placed within ReplicatedStorage.

### Crystal
Include a `require` statement for Crystal.
<details class="note">
<summary>Snippet</summary>

```json
"Crystal": {
	"prefix": ["Crystal"],
	"body": ["local Crystal = require(ReplicatedStorage.Packages.Crystal)"],
	"description": "Require the Crystal module"
}
```

</details>
<details class="success">
<summary>Code Result</summary>

```lua
local Crystal = require(ReplicatedStorage.Packages.Crystal)
```

</details>

-------------------------------------

### Service
Reference a Roblox service.

<details class="note">
<summary>Snippet</summary>

```json
"Service": {
	"prefix": ["service"],
	"body": ["local ${0:Name}Service = game:GetService(\"${0:Name}Service\")"],
	"description": "Roblox Service"
}
```
</details>
<details class="success">
<summary>Code Result</summary>

```lua
local HttpService = game:GetService("HttpService")
```

</details>

-------------------------------------

### Crystal Service
Reference Crystal, create a service, and return the service.
<details class="note">
<summary>Snippet</summary>

```json
"Crystal Service": {
	"prefix": ["Crystalservice"],
	"body": [
		"local Crystal = require(ReplicatedStorage.Packages.Crystal)",
		"",
		"local ${0:$TM_FILENAME_BASE} = Crystal.CreateService {",
		"\tName = \"${0:$TM_FILENAME_BASE}\",",
		"\tClient = {},",
		"}",
		"",
		"",
		"function ${0:$TM_FILENAME_BASE}:CrystalStart()",
		"\t",
		"end",
		"",
		"",
		"function ${0:$TM_FILENAME_BASE}:CrystalInit()",
		"\t",
		"end",
		"",
		"",
		"return ${0:$TM_FILENAME_BASE}",
		""
	],
	"description": "Crystal Service template"
}
```

</details>
<details class="success">
<summary>Code Result</summary>

```lua
local Crystal = require(ReplicatedStorage.Packages.Crystal)

local MyService = Crystal.CreateService {
	Name = "MyService",
	Client = {},
}

function MyService:CrystalStart()
end

function MyService:CrystalInit()
end

return MyService
```

</details>

-------------------------------------

### Crystal Controller
Reference Crystal, create a controller, and return the controller.
<details class="note">
<summary>Snippet</summary>

```json
"Crystal Controller": {
	"prefix": ["Crystalcontroller"],
	"body": [
		"local Crystal = require(ReplicatedStorage.Packages.Crystal)",
		"",
		"local ${0:$TM_FILENAME_BASE} = Crystal.CreateController { Name = \"${0:$TM_FILENAME_BASE}\" }",
		"",
		"",
		"function ${0:$TM_FILENAME_BASE}:CrystalStart()",
		"\t",
		"end",
		"",
		"",
		"function ${0:$TM_FILENAME_BASE}:CrystalInit()",
		"\t",
		"end",
		"",
		"",
		"return ${0:$TM_FILENAME_BASE}",
		""
	],
	"description": "Crystal Controller template"
}
```

</details>
<details class="success">
<summary>Code Result</summary>

```lua
local Crystal = require(ReplicatedStorage.Packages.Crystal)

local MyController = Crystal.CreateController {
	Name = "MyController",
}

function MyController:CrystalStart()
end

function MyController:CrystalInit()
end

return MyController
```

</details>

-------------------------------------

### Crystal Require
Require a module within Crystal.
<details class="note">
<summary>Snippet</summary>

```json
"Crystal Require": {
	"prefix": ["Crystalrequire"],
	"body": ["local ${1:Name} = require(Crystal.${2:Util}.${1:Name})"],
	"description": "Crystal Require template"
}
```

</details>
<details class="success">
<summary>Code Result</summary>

```lua
local Signal = require(Crystal.Util.Signal)
```

</details>

-------------------------------------

### Lua Class
A standard Lua class.

<details class="note">
<summary>Snippet</summary>

```json
"Class": {
	"prefix": ["class"],
	"body": [
		"local ${0:$TM_FILENAME_BASE} = {}",
		"${0:$TM_FILENAME_BASE}.__index = ${0:$TM_FILENAME_BASE}",
		"",
		"",
		"function ${0:$TM_FILENAME_BASE}.new()",
		"\tlocal self = setmetatable({}, ${0:$TM_FILENAME_BASE})",
		"\treturn self",
		"end",
		"",
		"",
		"function ${0:$TM_FILENAME_BASE}:Destroy()",
		"\t",
		"end",
		"",
		"",
		"return ${0:$TM_FILENAME_BASE}",
		""
	],
	"description": "Lua Class"
}
```

</details>
<details class="success">
<summary>Code Result</summary>

```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new()
	local self = setmetatable({}, MyClass)
	return self
end

function MyClass:Destroy()

end

return MyClass
```

</details>

-------------------------------------

### All
All the above snippets together.

<details class="note">
<summary>All Snippets</summary>

```json
{

	"Service": {
		"prefix": ["service"],
		"body": ["local ${0:Name}Service = game:GetService(\"${0:Name}Service\")"],
		"description": "Roblox Service"
	},

	"Class": {
		"prefix": ["class"],
		"body": [
			"local ${0:$TM_FILENAME_BASE} = {}",
			"${0:$TM_FILENAME_BASE}.__index = ${0:$TM_FILENAME_BASE}",
			"",
			"",
			"function ${0:$TM_FILENAME_BASE}.new()",
			"\tlocal self = setmetatable({}, ${0:$TM_FILENAME_BASE})",
			"\treturn self",
			"end",
			"",
			"",
			"function ${0:$TM_FILENAME_BASE}:Destroy()",
			"\t",
			"end",
			"",
			"",
			"return ${0:$TM_FILENAME_BASE}",
			""
		],
		"description": "Lua Class"
	},

	"Crystal": {
		"prefix": ["Crystal"],
		"body": ["local Crystal = require(ReplicatedStorage.Packages.Crystal)"],
		"description": "Require the Crystal module"
	},

	"Crystal Service": {
		"prefix": ["Crystalservice"],
		"body": [
			"local Crystal = require(ReplicatedStorage.Packages.Crystal)",
			"",
			"local ${0:$TM_FILENAME_BASE} = Crystal.CreateService {",
			"\tName = \"${0:$TM_FILENAME_BASE}\",",
			"\tClient = {},",
			"}",
			"",
			"",
			"function ${0:$TM_FILENAME_BASE}:CrystalStart()",
			"\t",
			"end",
			"",
			"",
			"function ${0:$TM_FILENAME_BASE}:CrystalInit()",
			"\t",
			"end",
			"",
			"",
			"return ${0:$TM_FILENAME_BASE}",
			""
		],
		"description": "Crystal Service template"
	},

	"Crystal Controller": {
		"prefix": ["Crystalcontroller"],
		"body": [
			"local Crystal = require(ReplicatedStorage.Packages.Crystal)",
			"",
			"local ${0:$TM_FILENAME_BASE} = Crystal.CreateController { Name = \"${0:$TM_FILENAME_BASE}\" }",
			"",
			"",
			"function ${0:$TM_FILENAME_BASE}:CrystalStart()",
			"\t",
			"end",
			"",
			"",
			"function ${0:$TM_FILENAME_BASE}:CrystalInit()",
			"\t",
			"end",
			"",
			"",
			"return ${0:$TM_FILENAME_BASE}",
			""
		],
		"description": "Crystal Controller template"
	},

	"Crystal Require": {
		"prefix": ["Crystalrequire"],
		"body": ["local ${1:Name} = require(Crystal.${2:Util}.${1:Name})"],
		"description": "Crystal Require template"
	}

}
```

</details>
