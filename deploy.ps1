# Copies the addon files into the game's AddOns folder. Source of truth is this repo; never edit the AddOns copy.
$dest = 'G:\Blizzard\World of Warcraft\_classic_beta_\Interface\AddOns\GamepadDot'
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item "$PSScriptRoot\GamepadDot.lua", "$PSScriptRoot\GamepadDot.toc" $dest -Force
Write-Host "Deployed to $dest. /reload in game."
