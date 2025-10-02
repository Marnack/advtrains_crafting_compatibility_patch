# AdvTrains Crafting Compatibility Patch API Reference Guide


*DISCLAIMER: This guide applies to the Beta release of this mod.  While an  attempt will be made to avoid breaking the API, some API changes might be necessary prior to the formal release of this mod.*

The **AdvTrains Crafting Compatibility Patch** provides support for using [AdvTrains](https://content.minetest.net/packages/orwell/advtrains/) in survival mode in games other than [Minetest Game](https://content.minetest.net/packages/Minetest/minetest_game/) and its many variants.  It does this by adding new crafting recipes for the craft items and nodes that are defined by AdvTrains that require input items from the current game instead of items from the mods specific to Minetest Game.  The list of other games for which this patch currently provides support includes the following games and their variants:

- [Farlands Reloaded](https://content.minetest.net/packages/wsor4035/farlands_reloaded/)
- [Hades Revisited](https://content.minetest.net/packages/Wuzzy/hades_revisited/)
- [Minecloneia](https://content.minetest.net/packages/ryvnf/mineclonia/)
- [VoxeLibre](https://content.minetest.net/packages/Wuzzy/mineclone2/)

It is important to note that as a patch, this mod is susceptible to being broken by future changes to AdvTrains as well as the games for which it provides compatibility support.  It could also be made obsolete by future changes to AdvTrains if crafting compatibility support becomes included in that mod.  This means that any mod that uses this mod's API will be similarly 
at risk of failing to function as expected.

## How to customize the behavior of the patch

Although the goal of this mod is to provide a default experience that is good for the majority of players, it also allows for customization when needed.  The behavior of this mod can be controlled both by changing the mod's setting as well as by creating a new mod that uses this mod's API.  As is standard for Minetest, mod settings apply to all games for a given installation of the Minetest engine.  One advantage of creating a new mod that uses the API is that it can be used for specific games.  Additionally, using a new mod also allows for customizing the material substitutions which is not currently possible to do via the mod settings.

### Mod Settings

The information in this section is copied from settingstype.txt and augmented with some additional detail in some cases.

- **advtrains_crafting_compatibility_patch_auto_apply**

>	Display Name: Automatically apply patch
>
>	Type: bool
>
>	Default Value: true
>
>	Specify if the patch should be applied when the mod is initialized. This setting should typically be enabled. Only in rare cases where another mod is using this mod's API to customize the patch behavior might this setting need to be disabled.  The other mod should provide documentation that indicates if this is needed.  This would typically be done as a minor performance optimization where there is no need to apply this patch's material mapping since another mod is going to use this mod's API to define its own material mapping.

- **advtrains_crafting_compatibility_patch_remove_original_recipes**

> Display Name: Remove original "Minetest Game" based recipes
>
> Type: bool
>
> Default Value: true
>
> This setting is intended to keep broken crafting recipes from appearing in the crafting guide. When enabled, the original recipes for AdvTrains will be removed when replacement recipes are added. If disabled, the AdvTrains recipes that require unavailable items will not be removed. In some cases, it may be necessary to disable this setting if another mod will also be updating the AdvTrains crafting recipes or adding alternate recipes for AdvTrains items.

- **advtrains_crafting_compatibility_patch_add_recipes_for_tools**

> Display Name: Add replacement recipes for tools
>
> Type: bool
>
> Default Value: true
>
> Update the recipes for AdvTrains tools.  If disabled, the original recipes for tools will not be changed or removed.

- **advtrains_crafting_compatibility_patch_add_recipes_for_track_items**

> Display Name: Add replacement recipes for track and track related items
>
> Type: bool
>
> Default Value: true
>
> Update the recipes for AdvTrains track and track related items.  If disabled, the original recipes for track and track related items will not be changed or removed.

- **advtrains_crafting_compatibility_patch_add_recipes_for_wagon_parts**

> Display Name: Add replacement recipes for wagon and locomotive parts
>
> Type: bool
>
> Default Value: true
>
> Update the recipes for AdvTrains wagon and locomotive parts.  If disabled, the original recipes for wagon and locomotive parts will not be changed or removed.

-  **advtrains_crafting_compatibility_patch_add_recipes_for_signs_and_signals**

> Display Name: Add replacement recipes for signs and signals
>
> Type: bool
>
> Default Value: true
>
> Update the recipes for AdvTrains signs and signals.  If disabled, the original recipes for signs and signals will not be changed or removed.


- **advtrains_crafting_compatibility_patch_add_recipes_for_platforms**

> Display Name: Add the train station platforms nodes and recipes
>
>Type: bool
>
> Default Value: false
>
> Add the nodes and recipes for AdvTrains train station platforms.  If disabled, the AdvTrains platform nodes and their recipes will not be added.  This is disabled by default because there is a small risk that a future update of AdvTrains or one of the game mods could break this patch such that the platform nodes become "Unknown Item" nodes. Only enable this setting if testing or if you are comfortable handling "Unknown Item" nodes (4 per platform material, typically 8 in total) if such a breakage occurs.

- **advtrains_crafting_compatibility_patch_debug_mode**

> Display Name: Debug mode
>
>Type: bool
>
> Default Value: false
>
> Enable additional debug messaging to be generated by this mod. It will 	likely only be needed when investigating an issue that might be related to this mod or when developing a new mod that uses this mod's API to alter its behavior.

### Customization with a new mod

If customizing the mod's behavior via its setting is not sufficient, using its API might be a good alternative.  Using the API, the material mapping can  be modified or even replaced altogether.

Each of the following two samples includes complete examples of the `mod.conf` and `init.lua` files that would be needed to create a working mod.

#### Sample #1

In this very simple contrived example, a single material substitution will be changed for games based on Minetest Game.  Specifically, the crafting recipes for AdvTrains that require a steel ingot will instead require a gold ingot.

The `mod.conf `file will need to declare a dependency on advtrains_crafting_compatibility_patch.
 
`mod.conf`:
```
name = patch_sample_1
description = Replace default:steel_ingot with default:gold_ingot for Minetest Game
depends = advtrains_crafting_compatibility_patch
min_minetest_version = 5.8
```

The code in the `init.lua` file checks if the current game is Minetest Game and if so, uses the API to get the default material mappings for the game and updates the mapping for steel_ingot to reference "default:gold_ingot".  It then uses the API again to update the crafting recipes.  Note  that `advtrains_crafting_compatibility_patch.update_crafting_recipes()` will use to the mod settings of **AdvTrains Crafting Compatibility Patch**.

`init.lua`:

```
-- In this example, only update the material mapping for games based on Minetest Game.
if minetest.get_modpath("default") and minetest.get_modpath("dye") then

    -- Get the material mappings based on the current game and installed mods.
    local materials = advtrains_crafting_compatibility_patch.get_materials_minetest_game()
    
    -- Override the mapping for steel ingot to use a gold ingot.
    materials.steel_ingot = "default:gold_ingot"
    
    -- Update the material mapping, reporting a failure if applicable.
    if not advtrains_crafting_compatibility_patch.update_crafting_recipes(materials) then
        minetest.debug("Patch not applied.")
    end
end
```

#### Sample #2

In this example, the [xcompat](https://content.minetest.net/packages/mt-mods/xcompat/) mod is used to provide a substitution mapping of the materials, replacing the built-in mapping provided by **AdvTrains Crafting Compatibility Patch**.

The `mod.conf` file will need to declare a dependency on *both*  advtrains_crafting_compatibility_patch and xcompat.

`mod.conf`:
```
name = patch_sample_2
description = Use xcompat to provide a substitution mapping of materials
depends = advtrains_crafting_compatibility_patch, xcompat
min_minetest_version = 5.8
```

The code in the `init.lua` file defines the table of items need by AdvTrains crafting recipes using xcompat (providing alternates whenever xcompat does not define a particular item), deletes the existing crafting recipes defined by AdvTrains (ignoring the **advtrains_crafting_compatibility_patch_remove_original_recipes** ("Remove original "Minetest Game" based recipes") mod setting), and then uses the API again to add the crafting recipes.

`init.lua`:
```
-- Define a material substitution table using values from xcompat whenever possible.
local materials = {
    chest                 = xcompat.materials.chest,
    diamond               = xcompat.materials.diamond,
    dye_black             = xcompat.materials.dye_black,
    dye_cyan              = xcompat.materials.dye_cyan,
    dye_dark_green        = xcompat.materials.dye_dark_green,
    dye_green             = xcompat.materials.dye_green,
    dye_orange            = xcompat.materials.dye_orange,
    dye_red               = xcompat.materials.dye_red,
    dye_white             = xcompat.materials.dye_white,
    dye_yellow            = xcompat.materials.dye_yellow,
    glass                 = xcompat.materials.glass ,
    gravel                = xcompat.materials.gravel,
    group_wood            = "group:wood",                      -- No group support in xcompat
    group_stick           = "group:stick",                     -- No group support in xcompat
    mese_crystal          = xcompat.materials.mese_crystal,
    mese_crystal_fragment = xcompat.materials.mese_crystal_fragment,
    paper                 = xcompat.materials.paper,
    sandstonebrick        = xcompat.materials.sandstone,       -- missing in xcompat, use alternate item
    screwdriver           = xcompat.materials.steel_ingot,     -- missing in xcompat, use alternate item
    sign_wall_steel       = xcompat.materials.steel_ingot,     -- missing in xcompat, use alternate item
    steel_ingot           = xcompat.materials.steel_ingot,
    stick                 = xcompat.materials.stick,
    stone                 = xcompat.materials.stone,
    stonebrick            = xcompat.materials.stone,           -- missing in xcompat, use alternate item
    torch                 = xcompat.materials.torch,
    trapdoor_steel        = xcompat.materials.steel_ingot,     -- missing in xcompat, use alternate item
}

-- Confirm that the material mapping table is valid.
if not advtrains_crafting_compatibility_patch.is_valid_materials_table(materials) then
    minetest.debug("Invalid materials. Customized patch not applied.")
    return
end
	
-- Ignore mod settings and force the removal of the existing recipes from AdvTrains.
advtrains_crafting_compatibility_patch.remove_recipes_tools()
advtrains_crafting_compatibility_patch.remove_recipes_track_items()
advtrains_crafting_compatibility_patch.remove_recipes_wagon_parts()
advtrains_crafting_compatibility_patch.remove_recipes_signs_and_signals()
advtrains_crafting_compatibility_patch.remove_recipes_platforms()

if not advtrains_crafting_compatibility_patch.update_crafting_recipes(materials) then
    minetest.debug("Update failed. Customized patch not applied.")
end
```

As can be seen in this sample, xcompat is lacking support for several items at the time of this writing.  Check for the latest version of xcompat in case these items have since been added to xcompat.

Another approach could be to use the [adaptation_modpack](https://content.minetest.net/packages/SFENCE/adaptation_modpack/) which is conceptually similar to xcompat.  That approach, however, is left as an exercise for the reader.

## Materials Used in AdvTrains crafting recipes
For quick reference, the following table shows the material input values used by AdvTrains at the time of this writing (AdvTrains release 2.8.0):

Material Input|Value used by AdvTrains
:---|:---
chest|default:chest
coal_lump|default:coal_lump
diamond|default:diamond
dye_black|dye:black
dye_cyan|dye:cyan
dye_dark_green|dye:dark_green
dye_green|dye:green
dye_orange|dye:orange
dye_red|dye:red
dye_white|dye:white
dye_yellow|dye:yellow
glass|default:glass
gravel|default:gravel
group_stick|group:stick
group_wood|group:wood
mese_crystal|default:mese_crystal
mese_crystal_fragment|default:mese_crystal_fragment
paper|default:paper
sandstonebrick|default:sandstonebrick
screwdriver|screwdriver:screwdriver
sign_wall_steel|default:sign_wall_steel
steel_ingot|default:steel_ingot
stick|default:stick
stone|default:stone
stonebrick|default:stonebrick
torch|default:torch
trapdoor_steel|doors:trapdoor_steel

Note that AdvTrains will sometimes substitute materials from other mods such as [Basic Materials](https://content.minetest.net/packages/mt-mods/basic_materials/) and [Technic](https://content.minetest.net/packages/RealBadAngel/technic/) if they are enabled.  This mod will also perform those substitutions.

Of course, the list of input materials and the values used by AdvTrains are all subject to change in future releases of AdvTrains.  Any such changes might require an update to this patch in order for it to continue functioning correctly.

## API Reference

The following is a list of all of the API functions.  Note that the **add_recipes_...()** and **remove_recipes_...()** functions should only be called during server start-up.

The `materials` parameter cited in the following list of API functions is a Lua table containing material names, each with an associated string that specifies the the material that should be used.  It is an error to omit a material from the table.  See the **Materials Used in AdvTrains crafting recipes** section above for the full list of required materials.  Also see Sample 2 in the **Customization with a new mod** section above for an example of creating the table.  Note that the various **get_materials...()** functions listed below always return a fully populated materials table.  These returned tables can then be modified as shown in Sample 1 and passed the the various **add_recipes_...()** functions.

- **is_valid_materials_table(materials)** - Checks if the given materials table has the required material entries.  See the **Materials Used in AdvTrains crafting recipes** section above for the full list of required materials.

- **get_materials_minetest_game()** - Get the material mapping for a game based on Minetest Game.

- **get_materials_mineclonia()** - Get the material mapping for a game based on Mineclonia.

- **get_materials_voxelibre()** - Get the material mapping for a game based on Voxelibre (Mineclone2).

- **get_materials_farlands_reloaded()** - Get the material mapping for a game based on Farlands Reloaded.

- **get_materials_hades_revisited()** - Get the material mapping for a game based on Hades Revisited.

- **get_materials()** - Get the material mapping for the currently detected game.  It returns `nil` if it could not identify the current game.

- **remove_recipes_tools()** - Remove all current crafting recipes for tools that require materials defined in mods outside of AdvTrains.

- **add_recipes_tools(materials)** - Add crafting recipes for tools using the given table of materials.  This list includes the recipes for the following items:
	+ "advtrains:trackworker"	*Note: This tool was previously grouped with "track items" in the first release of this mod.*
	+ "advtrains:wagon_prop_tool"
	+ "advtrains_interlocking:tool"
	+ "advtrains_luaautomation:oppanel" (if mod enabled)
	+ "advtrains_luaautomation:pcnaming" (if mod enabled)

- **remove_recipes_track_items()** - Remove all current crafting recipes related to track items that require materials defined in mods outside of AdvTrains.
  
- **add_recipes_track_items(materials)** - Add crafting recipes for track related items using the given table of materials.  This list includes the recipes for the following items:
	+ "advtrains:dtrack_bumper_placer"
	+ "advtrains:dtrack_load_placer"
	+ "advtrains:dtrack_placer"
	+ "advtrains:dtrack_slopeplacer"

- **remove_recipes_wagon_parts()** - Remove all current crafting recipes related to wagon parts that require materials defined in mods outside of AdvTrains.

- **add_recipes_wagon_parts(materials)** - Add crafting recipes for locomotive and wagon items using the given table of materials.  This list includes the recipes for the following items:
	+ "advtrains:boiler"
	+ "advtrains:chimney"
	+ "advtrains:driver_cab"
	+ "advtrains:wheel"

- **remove_recipes_signs_and_signals()** - Remove all current crafting recipes related to signs and signals that require materials defined in mods outside of AdvTrains.

- **add_recipes_signs_and_signals(materials)** - Add crafting recipes for signs and signals using the given table of materials.  This list includes the recipes for the following items:
	+ "advtrains:retrosignal_off"
	+ "advtrains:signal_off"
	+ "advtrains:signal_wall_l_off"
	+ "advtrains:signal_wall_r_off"
	+ "advtrains:signal_wall_t_off"
	+ "advtrains_interlocking:tcb_node" (if mod enabled)
	+ "advtrains_signals_ks:hs_danger_0" (if mod enabled)
	+ "advtrains_signals_ks:mast_mast_0" (if mod enabled)
	+ "advtrains_signals_ks:ra_danger_0" (if mod enabled)
	+ "advtrains_signals_ks:sign_8_0" (if mod enabled)
	+ "advtrains_signals_ks:vs_slow_0" (if mod enabled)
	+ "advtrains_signals_ks:zs3_off_0" (if mod enabled)
	+ "advtrains_signals_ks:zs3v_off_0" (if mod enabled)
	+ "advtrains_signals_muc_ubahn:signal_wall_l_hp0" (if mod enabled)
	+ "advtrains_signals_muc_ubahn:signal_wall_l_vr0" (if mod enabled)

- **remove_recipes_platforms()** - Remove all current crafting recipes related to platforms that require materials defined in mods outside of AdvTrains.

- **add_recipes_platforms(materials)** - Add crafting recipes *and the nodes* for platforms using the given table of materials.  This list includes the recipes for the following items:
	+ "advtrains:platform_low_stonebrick"
	+ "advtrains:platform_high_stonebrick"
	+ "advtrains:platform_45_stonebrick"
	+ "advtrains:platform_45_low_stonebrick"
	+ "advtrains:platform_low_sandstonebrick"
	+ "advtrains:platform_high_sandstonebrick"
	+ "advtrains:platform_45_sandstonebrick"
	+ "advtrains:platform_45_low_sandstonebrick"

- **update_crafting_recipes(materials)** - Updates the crafting recipes (and platform nodes as applicable) for the current game according to the **AdvTrains Crafting Compatibility Patch** mod settings using the given table of materials.  To ignore the mod settings, call the **remove_recipes_...()** and **add_recipes_...()** functions directly as needed instead of using this function.

## Special Note:

The API of the **AdvTrains Crafting Compatibility Patch** offers the possibility for mod developers to provide more control of its behavior as compared to the mod's settings.  However, there is a scenario where using the API can lead to some unexpected extra platform nodes.  This can be avoided by advising the user to disable one or both of the following mod settings when enabling a mod that uses this mod's API.

- **advtrains_crafting_compatibility_patch_auto_apply** ("Automatically apply patch")
- **advtrains_crafting_compatibility_patch_add_recipes_for_platforms** ("Add the train station platforms nodes and recipes")

In general, it's probably best to always disable the **advtrains_crafting_compatibility_patch_auto_apply** ("Automatically apply patch") mod setting anyway when enabling a mod that uses the API.

## Licenses

Copyright © 2024-2025 Marnack

- AdvTrains Crafting Compatibility Patch is licensed under the GNU AGPL version 3 license.
- Unless otherwise specified, AdvTrains Crafting Compatibility Patch media (textures and sounds) are licensed under [CC BY-SA 3.0 Unported](https://creativecommons.org/licenses/by-sa/3.0/).

