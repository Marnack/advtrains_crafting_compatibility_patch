local mod_name = minetest.get_current_modname()

advtrains_crafting_compatibility_patch = {}

local auto_apply = minetest.settings:get_bool("advtrains_crafting_compatibility_patch_auto_apply")
if auto_apply == nil then auto_apply = true end

local remove_original_recipes = minetest.settings:get_bool("advtrains_crafting_compatibility_patch_remove_original_recipes")
if remove_original_recipes == nil then remove_original_recipes = true end

local add_recipes_for_tools = minetest.settings:get_bool("advtrains_crafting_compatibility_patch_add_recipes_for_tools")
if add_recipes_for_tools == nil then add_recipes_for_tools = true end

local add_recipes_for_track_items = minetest.settings:get_bool("advtrains_crafting_compatibility_patch_add_recipes_for_track_items")
if add_recipes_for_track_items == nil then add_recipes_for_track_items = true end

local add_recipes_for_wagon_parts = minetest.settings:get_bool("advtrains_crafting_compatibility_patch_add_recipes_for_wagon_parts")
if add_recipes_for_wagon_parts == nil then add_recipes_for_wagon_parts = true end

local add_recipes_for_signs_and_signals = minetest.settings:get_bool("advtrains_crafting_compatibility_patch_add_recipes_for_signs_and_signals")
if add_recipes_for_signs_and_signals == nil then add_recipes_for_signs_and_signals = true end

local add_recipes_for_platforms = minetest.settings:get_bool("advtrains_crafting_compatibility_patch_add_recipes_for_platforms")
if add_recipes_for_platforms == nil then add_recipes_for_platforms = false end

local debug_mode = minetest.settings:get_bool("advtrains_crafting_compatibility_patch_debug_mode")
if debug_mode == nil then debug_mode = false end

local enabled_mods = {
	advtrains_interlocking = minetest.get_modpath("advtrains_interlocking") and true,
	advtrains_line_automation = minetest.get_modpath("advtrains_line_automation") and true,
	advtrains_luaautomation = minetest.get_modpath("advtrains_luaautomation") and minetest.settings:get_bool("advtrains_luaautomation_enable_atlac_recipes", false) == true,
	advtrains_signals_ks = minetest.get_modpath("advtrains_signals_ks") and true,
	advtrains_signals_muc_ubahn = minetest.get_modpath("advtrains_signals_muc_ubahn") and true,
}

local function log_info(msg)
	if debug_mode then
		minetest.debug("["..mod_name.."] "..msg)
	else
		minetest.log("info", "["..mod_name.."] "..msg)
	end
end

local required_material_names = {
	"chest",
	"coal_lump",
	"diamond",
	"dye_black",
	"dye_cyan",
	"dye_dark_green",
	"dye_green",
	"dye_orange",
	"dye_red",
	"dye_white",
	"dye_yellow",
	"glass",
	"gravel",
	"group_stick",
	"group_wood",
	"mese_crystal",
	"mese_crystal_fragment",
	"paper",
	"sandstonebrick",
	"screwdriver",
	"sign_wall_steel",
	"steel_ingot",
	"stick",
	"stone",
	"stonebrick",
	"torch",
	"trapdoor_steel",
}

-- Since this mod provides an API, this utility is used to validate the input.
function advtrains_crafting_compatibility_patch.is_valid_materials_table(materials)
	if not materials then
		return false
	end

	for _, name in ipairs(required_material_names) do
		if not materials[name] or materials[name] == "" then
			log_info("Missing or invalid material: "..name)
			return false
		end
	end

	return true
end

-- ================================================================================================
-- Utilities to get game specific materials (based on currently enabled mods)
-- ================================================================================================

function advtrains_crafting_compatibility_patch.get_materials_minetest_game()
	return {
		base_game				= "Minetest Game",

		chest					= "default:chest",
		coal_lump				= "default:coal_lump",
		diamond					= "default:diamond",
		dye_black				= "dye:black",
		dye_cyan				= "dye:cyan",
		dye_dark_green			= "dye:dark_green",
		dye_green				= "dye:green",
		dye_orange				= "dye:orange",
		dye_red					= "dye:red",
		dye_white				= "dye:white",
		dye_yellow				= "dye:yellow",
		glass					= "default:glass",
		gravel					= "default:gravel",
		group_wood				= "group:wood",
		group_stick				= "group:stick",
		mese_crystal			= "default:mese_crystal",
		mese_crystal_fragment	= "default:mese_crystal_fragment",
		paper					= "default:paper",
		sandstonebrick			= "default:sandstonebrick",
		screwdriver				= minetest.get_modpath("screwdriver") and "screwdriver:screwdriver" or "default:steel_ingot",
		sign_wall_steel			= "default:sign_wall_steel",
		steel_ingot				= "default:steel_ingot",
		stick					= "default:stick",
		stone					= "default:stone",
		stonebrick				= "default:stonebrick",
		torch					= "default:torch",
		trapdoor_steel			= minetest.get_modpath("doors") and "doors:trapdoor_steel" or "default:steel_ingot",
	}
end

function advtrains_crafting_compatibility_patch.get_materials_mineclonia()
	return {
		base_game				= "Mineclonia",

		chest					=  minetest.get_modpath("mcl_chests") and "mcl_chests:chest" or "group:wood",
		coal_lump				= "mcl_core:coal_lump",
		diamond					= "mcl_core:diamond",
		dye_black				= "mcl_dyes:black",
		dye_cyan				= "mcl_dyes:cyan",
		dye_dark_green			= "mcl_dyes:dark_green",
		dye_green				= "mcl_dyes:green",
		dye_orange				= "mcl_dyes:orange",
		dye_red					= "mcl_dyes:red",
		dye_white				= "mcl_dyes:white",
		dye_yellow				= "mcl_dyes:yellow",
		glass					= "mcl_core:glass",
		gravel					= "mcl_core:gravel",
		group_wood				= "group:wood",
		group_stick				= "group:stick",
		mese_crystal			= minetest.get_modpath("mesecons") and "mesecons:redstone" or "mcl_core:lapis",
		mese_crystal_fragment	= "mcl_core:emerald",		-- A compromise alternative
		paper					= "mcl_core:paper",
		sandstonebrick			= "mcl_core:sandstone",
		screwdriver				= minetest.get_modpath("screwdriver") and "screwdriver:screwdriver" or "mcl_core:iron_ingot",
		sign_wall_steel			= "mcl_core:iron_ingot",	-- A compromise alternative
		steel_ingot				= "mcl_core:iron_ingot",
		stick					= "mcl_core:stick",
		stone					= "mcl_core:stone",
		stonebrick				= "mcl_core:stonebrick",
		torch					= minetest.get_modpath("mcl_torches") and "mcl_torches:torch" or "group:coal",
		trapdoor_steel			= minetest.get_modpath("mcl_doors") and "mcl_doors:iron_trapdoor", "mcl_core:iron_ingot",
	}
end

function advtrains_crafting_compatibility_patch.get_materials_voxelibre()
	return {
		base_game				= "VoxeLibre/MineClone2",

		chest					=  minetest.get_modpath("mcl_chests") and "mcl_chests:chest" or "group:wood",
		coal_lump				= "mcl_core:coal_lump",
		diamond					= "mcl_core:diamond",
		dye_black				= "mcl_dye:black",
		dye_cyan				= "mcl_dye:cyan",
		dye_dark_green			= "mcl_dye:dark_green",
		dye_green				= "mcl_dye:green",
		dye_orange				= "mcl_dye:orange",
		dye_red					= "mcl_dye:red",
		dye_white				= "mcl_dye:white",
		dye_yellow				= "mcl_dye:yellow",
		glass					= "mcl_core:glass",
		gravel					= "mcl_core:gravel",
		group_wood				= "group:wood",
		group_stick				= "group:stick",
		mese_crystal			= minetest.get_modpath("mesecons") and "mesecons:redstone" or "mcl_core:lapis",
		mese_crystal_fragment	= "mcl_core:emerald",		-- A compromise alternative
		paper					= "mcl_core:paper",
		sandstonebrick			= "mcl_core:sandstone",
		screwdriver				= minetest.get_modpath("screwdriver") and "screwdriver:screwdriver" or "mcl_core:iron_ingot",
		sign_wall_steel			= "mcl_core:iron_ingot",	-- A compromise alternative
		steel_ingot				= "mcl_core:iron_ingot",
		stick					= "mcl_core:stick",
		stone					= "mcl_core:stone",
		stonebrick				= "mcl_core:stonebrick",
		torch					= minetest.get_modpath("mcl_torches") and "mcl_torches:torch" or "group:coal",
		trapdoor_steel			= minetest.get_modpath("mcl_doors") and "mcl_doors:iron_trapdoor", "mcl_core:iron_ingot",
	}
end

function advtrains_crafting_compatibility_patch.get_materials_farlands_reloaded()
	return {
		base_game				= "Farlands Reloaded",

		chest					= minetest.get_modpath("fl_storage") and "fl_storage:wood_chest" or "group:plank",
		coal_lump				= "fl_ores:coal_ore",
		diamond					= "fl_ores:diamond_ore",
		dye_black				= "fl_dyes:black_dye",
		dye_cyan				= "fl_dyes:cyan_dye",
		dye_dark_green			= "fl_dyes:dark_green_dye",
		dye_green				= "fl_dyes:green_dye",
		dye_orange				= "fl_dyes:orange_dye",
		dye_red					= "fl_dyes:red_dye",
		dye_white				= "fl_dyes:white_dye",
		dye_yellow				= "fl_dyes:yellow_dye",
		glass					= "fl_glass:framed_glass",
		gravel					= minetest.get_modpath("fl_topsoil") and "fl_topsoil:gravel" or "fl_stone:stone_rubble",
		group_wood				= "group:plank",
		group_stick				= "fl_trees:stick",
		mese_crystal			= "fl_ores:mithite_ore",
		mese_crystal_fragment	= "fl_ores:gold_ingot",		-- A compromise alternative
		paper					= "fl_trees:palm_leaves",	-- A compromise alternative
		sandstonebrick			= "fl_stone:sandstone_brick",
		screwdriver				= minetest.get_modpath("screwdriver") and "screwdriver:screwdriver" or "fl_ores:iron_ingot",
		sign_wall_steel			= "fl_ores:iron_ingot",		-- A compromise alternative
		steel_ingot				= "fl_ores:iron_ingot",
		stick					= "fl_trees:stick",
		stone					= "fl_stone:stone",
		stonebrick				= "fl_stone:stone_brick",
		torch					= minetest.get_modpath("fl_light_sources") and "fl_light_sources:torch" or "fl_ores:coal_ore",
		trapdoor_steel			= minetest.get_modpath("fl_doors") and "fl_doors:steel_door_a" or "fl_ores:iron_ingot",
	}
end

function advtrains_crafting_compatibility_patch.get_materials_hades_revisited()
	return {
		base_game				= "Hades Revisited",

		chest					= minetest.get_modpath("hades_chests") and "hades_chests:chest" or "group:wood",
		coal_lump				= "hades_core:coal_lump",
		diamond					= "hades_core:diamond",
		dye_black				= "hades_dye:black",
		dye_cyan				= "hades_dye:cyan",
		dye_dark_green			= "hades_dye:dark_green",
		dye_green				= "hades_dye:green",
		dye_orange				= "hades_dye:orange",
		dye_red					= "hades_dye:red",
		dye_white				= "hades_dye:white",
		dye_yellow				= "hades_dye:yellow",
		glass					= "hades_core:glass",
		gravel					= "hades_core:gravel",
		group_wood				= "group:wood",
		group_stick				= "group:stick",
		mese_crystal			= "hades_core:mese_crystal",
		mese_crystal_fragment	= "hades_core:mese_crystal_fragment",
		paper					= "hades_core:paper",
		sandstonebrick			= "hades_core:sandstonebrick",
		screwdriver				= minetest.get_modpath("screwdriver") and "screwdriver:screwdriver" or "hades_core:steel_ingot",
		sign_wall_steel			= minetest.get_modpath("signs_lib") and "signs_lib:sign_wall_white_black" or "hades_core:steel_ingot",
		steel_ingot				= "hades_core:steel_ingot",
		stick					= "hades_core:stick",
		stone					= "hades_core:stone",
		stonebrick				= "hades_core:stonebrick",
		torch					= minetest.get_modpath("hades_torches") and "hades_torches:torch_low" or "hades_core:coal_lump",
		trapdoor_steel			= minetest.get_modpath("hades_doors") and "hades_doors:trapdoor_steel" or "hades_core:steel_ingot",
	}
end

-- ================================================================================================
-- Utility to get materials for advtrains that are applicable to the current game
-- ================================================================================================

function advtrains_crafting_compatibility_patch.get_materials()
	if minetest.get_modpath("default") and minetest.get_modpath("doors") and minetest.get_modpath("dye") and minetest.get_modpath("screwdriver") then
		-- All of the needed mods for Minetest Game are available.  No substitutions are needed.
		log_info("Detected base game: Minetest Game (including all necessary mods)")
		return nil
	end

	if minetest.get_modpath("default") and minetest.get_modpath("dye") then
		-- Some of the standard materials from Minetest Game might need substitution
		return advtrains_crafting_compatibility_patch.get_materials_minetest_game()
	end

	if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_dyes") then
		return advtrains_crafting_compatibility_patch.get_materials_mineclonia()
	end

	if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_dye") then
		return advtrains_crafting_compatibility_patch.get_materials_voxelibre()
	end

	if minetest.get_modpath("fl_dyes") and minetest.get_modpath("fl_glass") and minetest.get_modpath("fl_ores") and minetest.get_modpath("fl_stone") and minetest.get_modpath("fl_trees") then
		return advtrains_crafting_compatibility_patch.get_materials_farlands_reloaded()
	end

	if minetest.get_modpath("hades_core") and minetest.get_modpath("hades_dye") then
		return advtrains_crafting_compatibility_patch.get_materials_hades_revisited()
	end

	log_info("Detected base game is not known to this mod.")
	return nil
end

-- ================================================================================================
-- Category: Recipes for Tools
-- ================================================================================================

function advtrains_crafting_compatibility_patch.remove_recipes_tools()
	minetest.clear_craft({output = "advtrains:trackworker"})
	minetest.clear_craft({output = "advtrains:wagon_prop_tool"})
	minetest.clear_craft({output = "advtrains_interlocking:tool"})
	minetest.clear_craft({output = "advtrains_luaautomation:oppanel"})
	minetest.clear_craft({output = "advtrains_luaautomation:pcnaming"})
--	minetest.clear_craft({output = "advtrains_line_automation:stanicni_rozhlas"})	-- not yet enabled in Advtrains
end

function advtrains_crafting_compatibility_patch.add_recipes_tools(materials)
	if not advtrains_crafting_compatibility_patch.is_valid_materials_table(materials) then
		minetest.debug("["..mod_name.."] Attempted to add crafting recipes for tools based on an invalid materials table.  Operation aborted")
		return false
	end

	minetest.register_craft({
		output = "advtrains:trackworker",
		recipe = {
			{materials.diamond},
			{materials.screwdriver},
			{materials.steel_ingot},
		},
	})

	minetest.register_craft({
		output = "advtrains:wagon_prop_tool",
		recipe = {
			{"advtrains:dtrack_placer", materials.dye_black, materials.paper},
			{materials.screwdriver, materials.paper, materials.paper},
			{"", "", materials.group_wood},
		},
	})

	if enabled_mods.advtrains_interlocking then
		minetest.register_craft({
			output = "advtrains_interlocking:tool",
			type = "shapeless",
			recipe = {materials.dye_green, "advtrains:trackworker", "advtrains_interlocking:tcb_node"}
		})
	end

	if enabled_mods.advtrains_luaautomation then
		minetest.register_craft({
			output = "advtrains_luaautomation:oppanel",
			recipe = {
				{"", "mesecons_button:button_off", ""},
				{"", "advtrains_luaautomation:mesecon_controller0000", ""},
				{"", materials.stone, ""},
			}
		})

		minetest.register_craft({
			output = "advtrains_luaautomation:pcnaming",
			type = "shapeless",
			recipe = {materials.dye_red, "advtrains:trackworker"}
		})
	end

	-- The following is not yet enabled in Advtrains
	--[[
	if enabled_mods.advtrains_line_automation then
		core.register_craft({
			output = "advtrains_line_automation:stanicni_rozhlas",
			recipe = {
				{materials.steel_ingot, materials.steel_ingot, materials.steel_ingot},
				{materials.steel_ingot, "mesecons_noteblock:noteblock", materials.steel_ingot},
				{materials.steel_ingot, materials.steel_ingot, materials.steel_ingot},
			},
		})
	end
	--]]

	return true
end

-- ================================================================================================
-- Category: Recipes for Track Related Items
-- ================================================================================================

function advtrains_crafting_compatibility_patch.remove_recipes_track_items()
	minetest.clear_craft({output = "advtrains:dtrack_bumper_placer"})
	minetest.clear_craft({output = "advtrains:dtrack_load_placer"})		-- This will also clear an additional recipe that is needed.
	minetest.clear_craft({output = "advtrains:dtrack_placer"})
	minetest.clear_craft({output = "advtrains:dtrack_slopeplacer"})
	minetest.clear_craft({output = "advtrains_line_automation:dtrack_stop_placer"})

	-- Restore any needed recipes that were removed by one of the preceeding calls to minetest.clear_craft()
	minetest.register_craft({
		type="shapeless",
		output = "advtrains:dtrack_load_placer",
		recipe = {
			"advtrains:dtrack_unload_placer",
		},
	})
end

function advtrains_crafting_compatibility_patch.add_recipes_track_items(materials)
	if not advtrains_crafting_compatibility_patch.is_valid_materials_table(materials) then
		minetest.debug("["..mod_name.."] Attempted to add crafting recipes for track items based on an invalid materials table.  Operation aborted")
		return false
	end

	-- Handle mod dependent material variations supported by advtrains.
	local loader_core = materials.mese_crystal
	if minetest.get_modpath("basic_materials") then
		loader_core = "basic_materials:ic"
	elseif minetest.get_modpath("technic") then
		loader_core = "technic:control_logic_unit"
	end

	minetest.register_craft({
		output = "advtrains:dtrack_bumper_placer 2",
		recipe = {
			{materials.group_wood, materials.dye_red},
			{materials.steel_ingot, materials.steel_ingot},
			{"advtrains:dtrack_placer", "advtrains:dtrack_placer"},
		},
	})

	minetest.register_craft({
		type="shapeless",
		output = "advtrains:dtrack_load_placer",
		recipe = {
			"advtrains:dtrack_placer",
			loader_core,
			materials.chest
		},
	})

	minetest.register_craft({
		output = "advtrains:dtrack_placer 50",
		recipe = {
			{materials.steel_ingot, materials.group_stick, materials.steel_ingot},
			{materials.steel_ingot, materials.group_stick, materials.steel_ingot},
			{materials.steel_ingot, materials.group_stick, materials.steel_ingot},
		},
	})

	minetest.register_craft({
		type = "shapeless",
		output = "advtrains:dtrack_slopeplacer 2",
		recipe = {
			"advtrains:dtrack_placer",
			"advtrains:dtrack_placer",
			materials.gravel,
		},
	})

	if enabled_mods.advtrains_line_automation then
		minetest.register_craft({
			output = "advtrains_line_automation:dtrack_stop_placer 2",
			recipe = {
				{materials.coal_lump, ""},
				{"advtrains:dtrack_placer", "advtrains:dtrack_placer"},
			},
		})
	end

	return true
end

-- ================================================================================================
-- Category: Recipes for Wagon and Locomotive Parts
-- ================================================================================================

function advtrains_crafting_compatibility_patch.remove_recipes_wagon_parts()
	minetest.clear_craft({output = "advtrains:boiler"})
	minetest.clear_craft({output = "advtrains:chimney"})
	minetest.clear_craft({output = "advtrains:driver_cab"})
	minetest.clear_craft({output = "advtrains:wheel"})
end

function advtrains_crafting_compatibility_patch.add_recipes_wagon_parts(materials)
	if not advtrains_crafting_compatibility_patch.is_valid_materials_table(materials) then
		minetest.debug("["..mod_name.."] Attempted to add crafting recipes for wagon parts based on an invalid materials table.  Operation aborted")
		return false
	end

	minetest.register_craft({
		output = "advtrains:boiler",
		recipe = {
			{materials.steel_ingot, materials.steel_ingot, materials.steel_ingot},
			{materials.trapdoor_steel, "", materials.steel_ingot},
			{materials.steel_ingot, materials.steel_ingot, materials.steel_ingot},
		},
	})

	minetest.register_craft({
		output = "advtrains:chimney",
		recipe = {
			{"", materials.steel_ingot, ""},
			{"", materials.steel_ingot, materials.torch},
			{"", materials.steel_ingot, ""},
		},
	})

	minetest.register_craft({
		output = "advtrains:driver_cab",
		recipe = {
			{materials.steel_ingot, materials.steel_ingot, materials.steel_ingot},
			{"", "", materials.glass},
			{materials.steel_ingot, materials.steel_ingot, materials.steel_ingot},
		},
	})

	minetest.register_craft({
		output = "advtrains:wheel",
		recipe = {
			{"", materials.steel_ingot, ""},
			{materials.steel_ingot, materials.group_stick, materials.steel_ingot},
			{"", materials.steel_ingot, ""},
		},
	})

	return true
end

-- ================================================================================================
-- Category: Recipes for Signs and Signals
-- ================================================================================================

function advtrains_crafting_compatibility_patch.remove_recipes_signs_and_signals()
	minetest.clear_craft({output = "advtrains:retrosignal_off"})
	minetest.clear_craft({output = "advtrains:signal_off"})
	minetest.clear_craft({output = "advtrains:signal_wall_l_off"})		-- This will also clear an additional recipe that is needed.
	minetest.clear_craft({output = "advtrains:signal_wall_r_off"})		-- This will also clear an additional recipe that is needed.
	minetest.clear_craft({output = "advtrains:signal_wall_t_off"})		-- This will also clear an additional recipe that is needed.
	minetest.clear_craft({output = "advtrains_interlocking:tcb_node"})
	minetest.clear_craft({output = "advtrains_signals_ks:hs_danger_0"})
	minetest.clear_craft({output = "advtrains_signals_ks:mast_mast_0"})
	minetest.clear_craft({output = "advtrains_signals_ks:ra_danger_0"})
	minetest.clear_craft({output = "advtrains_signals_ks:sign_8_0"})	-- This will also clear an additional recipe that is needed.
	minetest.clear_craft({output = "advtrains_signals_ks:vs_slow_0"})
	minetest.clear_craft({output = "advtrains_signals_ks:zs3_off_0"})
	minetest.clear_craft({output = "advtrains_signals_ks:zs3v_off_0"})
	minetest.clear_craft({output = "advtrains_signals_muc_ubahn:signal_wall_l_hp0"})	-- This will also clear an additional recipe that is needed.
	minetest.clear_craft({output = "advtrains_signals_muc_ubahn:signal_wall_l_vr0"})	-- This will also clear an additional recipe that is needed.

	-- Restore any needed recipes that were removed by one of the preceeding calls to minetest.clear_craft()
	minetest.register_craft({
		output = 'advtrains:signal_wall_l_off',
		type = "shapeless",
		recipe = {'advtrains:signal_wall_r_off'},
	})

	minetest.register_craft({
		output = "advtrains:signal_wall_r_off",
		type = "shapeless",
		recipe = {"advtrains:signal_wall_t_off"},
	})

	minetest.register_craft({
		output = 'advtrains:signal_wall_t_off',
		type = "shapeless",
		recipe = {'advtrains:signal_wall_l_off'},
	})

	if enabled_mods.advtrains_signals_ks then
		minetest.register_craft{
			output = "advtrains_signals_ks:sign_8_0",
			recipe = {{"advtrains_signals_ks:sign_lf7_8_0"}}
		}
	end

	if enabled_mods.advtrains_signals_muc_ubahn then
		minetest.register_craft{
			output = "advtrains_signals_muc_ubahn:signal_wall_l_hp0",
			type = "shapeless",
			recipe = {"advtrains_signals_muc_ubahn:signal_wall_r_hp0"},
		}

		minetest.register_craft{
			output = "advtrains_signals_muc_ubahn:signal_wall_l_vr0",
			type = "shapeless",
			recipe = {"advtrains_signals_muc_ubahn:signal_wall_r_vr0"},
		}
	end
end

function advtrains_crafting_compatibility_patch.add_recipes_signs_and_signals(materials)
	if not advtrains_crafting_compatibility_patch.is_valid_materials_table(materials) then
		minetest.debug("["..mod_name.."] Attempted to add crafting recipes for signs and signals based on an invalid materials table.  Operation aborted")
		return false
	end

	minetest.register_craft({
		output = "advtrains:retrosignal_off 2",
		recipe = {
			{materials.dye_red, materials.steel_ingot, materials.steel_ingot},
			{"", "", materials.steel_ingot},
			{"", "", materials.steel_ingot},
		},
	})

	minetest.register_craft({
		output = "advtrains:signal_off 2",
		recipe = {
			{"", materials.dye_red, materials.steel_ingot},
			{"", materials.dye_dark_green, materials.steel_ingot},
			{"", "", materials.steel_ingot},
		},
	})

	minetest.register_craft({
		output = 'advtrains:signal_wall_l_off 2',
		recipe = {
			{materials.steel_ingot, materials.steel_ingot, materials.dye_red},
			{"", materials.steel_ingot, ""},
			{materials.steel_ingot, materials.steel_ingot, materials.dye_dark_green},
		},
	})

	minetest.register_craft({
		output = "advtrains:signal_wall_r_off 2",
		recipe = {
			{materials.dye_red, materials.steel_ingot, materials.steel_ingot},
			{"", materials.steel_ingot, ""},
			{materials.dye_dark_green, materials.steel_ingot, materials.steel_ingot},
		},
	})

	minetest.register_craft({
		output = 'advtrains:signal_wall_t_off 2',
		recipe = {
			{materials.steel_ingot, "", materials.steel_ingot},
			{materials.steel_ingot, materials.steel_ingot, materials.steel_ingot},
			{materials.dye_dark_green, "", materials.dye_red},
		},
	})

	if enabled_mods.advtrains_signals_ks then

		-- Handle mod dependent material variations supported by advtrains.
		local sign_material = materials.sign_wall_steel
		if minetest.get_modpath("basic_materials") then
			sign_material = "basic_materials:plastic_sheet"
		end

		minetest.register_craft({
			output = "advtrains_signals_ks:vs_slow_0 2",
			recipe = {
				{materials.steel_ingot, materials.steel_ingot, materials.steel_ingot},
				{materials.dye_dark_green, materials.steel_ingot, materials.dye_yellow},
				{materials.steel_ingot, 'advtrains_signals_ks:mast_mast_0', materials.steel_ingot},
			}
		})

		minetest.register_craft({
			output = "advtrains_signals_ks:hs_danger_0 2",
			recipe = {
				{materials.steel_ingot, materials.dye_red, materials.steel_ingot},
				{materials.dye_yellow, materials.steel_ingot, materials.dye_dark_green},
				{materials.steel_ingot, "advtrains_signals_ks:mast_mast_0", materials.steel_ingot},
			},
		})

		minetest.register_craft({
			output = "advtrains_signals_ks:mast_mast_0 10",
			recipe = {
				{materials.steel_ingot},
				{materials.dye_cyan},
				{materials.steel_ingot},
			},
		})

		minetest.register_craft({
			output = "advtrains_signals_ks:ra_danger_0 2",
			recipe = {
				{materials.dye_red, materials.dye_white, materials.dye_red},
				{materials.dye_white, materials.steel_ingot, materials.steel_ingot},
				{materials.steel_ingot, "advtrains_signals_ks:mast_mast_0", materials.steel_ingot},
			},
		})

		minetest.register_craft({
			output = "advtrains_signals_ks:sign_8_0 2",
			recipe = {
				{sign_material, materials.dye_black},
				{materials.stick, ""},
				{materials.stick, ""},
			},
		})

		minetest.register_craft({
			output = "advtrains_signals_ks:zs3_off_0 2",
			recipe = {
				{"", materials.steel_ingot, ""},
				{materials.steel_ingot , materials.dye_white, materials.steel_ingot},
				{"", "advtrains_signals_ks:mast_mast_0", ""}
			},
		})

		minetest.register_craft({
			output = "advtrains_signals_ks:zs3v_off_0 2",
			recipe = {
				{"", materials.steel_ingot, ""},
				{materials.steel_ingot , materials.dye_yellow, materials.steel_ingot},
				{"", "advtrains_signals_ks:mast_mast_0", ""}
			},
		})
	end

	if enabled_mods.advtrains_signals_muc_ubahn then
		if enabled_mods.advtrains_interlocking then	-- Recipe requires tcb_node from this mod
			minetest.register_craft({
				output = "advtrains_signals_muc_ubahn:signal_wall_l_hp0",
				type = "shapeless",
				recipe = {"advtrains:signal_wall_l_off", "advtrains_interlocking:tcb_node"},
			})
		end

		minetest.register_craft({
			output = "advtrains_signals_muc_ubahn:signal_wall_l_vr0",
			recipe = {
				{materials.dye_orange, "", ""},
				{materials.dye_orange, "advtrains_signals_muc_ubahn:signal_wall_l_hp0", materials.dye_dark_green},
				{"", "", materials.dye_dark_green}
			}
		})
	end

	if enabled_mods.advtrains_interlocking then

		-- Handle mod dependent material variations supported by advtrains.
		local tcb_core = materials.mese_crystal
		if minetest.get_modpath("basic_materials") then
			tcb_core = "basic_materials:ic"
		elseif minetest.get_modpath("technic") then
			tcb_core = "technic:control_logic_unit"
		end

		local tcb_secondary = materials.mese_crystal_fragment
		if minetest.get_modpath("mesecons") then
			tcb_secondary = "mesecons:wire_00000000_off"
		end

		minetest.register_craft({
			output = "advtrains_interlocking:tcb_node 4",
			recipe = {
				{tcb_secondary,tcb_core,tcb_secondary},
				{"advtrains:dtrack_placer","","advtrains:dtrack_placer"}
			},
			replacements = {
				{"advtrains:dtrack_placer","advtrains:dtrack_placer"},
				{"advtrains:dtrack_placer","advtrains:dtrack_placer"},
			}
		})
	end

	return true
end

-- ================================================================================================
-- Category: Nodes and Recipes for Platforms
-- ================================================================================================

local platform_types = {
	":platform_low_",
	":platform_high_",
	":platform_45_",
	":platform_45_low_",
}

-- Track the platform materials for which recipes (may) have been registerd.  If another mod uses
-- this mod's API and the add_recipes_for_platforms mod setting is enabled, this will support
-- removing the platform recipes created during auto apply.
local prior_platform_materials = {"default:stonebrick", "default:sandstonebrick"}

local function get_node_name(node_fullname)
	return string.match(node_fullname, ":(.+)$")
end

local function are_advtrains_platforms_defined(nodename)
	-- Determine if advtrains has already created the platform nodes for the given
	-- material. (The test here assumes that if the node for high platforms has been
	-- created then all four platform nodes have already been created.)
	return minetest.registered_nodes["advtrains:platform_high_"..nodename] and true
end

local function unregister_craft_platform(node_fullname)
	local nodename = get_node_name(node_fullname)
	local mod_prefix = mod_name
	if are_advtrains_platforms_defined(nodename) then
		mod_prefix = "advtrains"
	end
	for _, platform_type in pairs(platform_types) do
		local platform_name = mod_prefix..platform_type..nodename
		minetest.clear_craft({output = platform_name})
	end
end

local function register_craft_platform(node_fullname, materials)
	local ndef=minetest.registered_nodes[node_fullname]
	if not ndef then
		-- Skip if node is not defined.
		log_info("Unable to register platforms for "..node_fullname..".  (Node is not currently defined, perhaps due to a missing optional dependency.)")
		return
	end

	local nodename = get_node_name(node_fullname)
	local mod_prefix = mod_name
	if are_advtrains_platforms_defined(nodename) then
		-- Use the appropriate mod name prefix for any platform nodes that were previously
		-- registered by the advtrains mod.
		mod_prefix = "advtrains"
	else
		-- Register the four new platform nodes for the given node_fullname if not already
		-- registered.  (The test here assumes that if the node for high platforms has been
		-- created then all four platform nodes have already been created.)
		if not minetest.registered_nodes[mod_name.. ":platform_high_"..nodename] then
			advtrains.register_platform(":"..mod_name, node_fullname)	-- Include ":" prefix to support API usage

			-- Remove the crafting recipes that were just created by the preceeding call to
			-- advtrains.register_platform() since the resulting recipes likely won't have
			-- the correct materials.
			unregister_craft_platform(node_fullname)
		end
	end

	minetest.register_craft({
		type="shapeless",
		output = mod_prefix..":platform_high_"..nodename.." 4",
		recipe = {
			materials.dye_yellow, node_fullname, node_fullname
		},
	})
	minetest.register_craft({
		type="shapeless",
		output = mod_prefix..":platform_low_"..nodename.." 4",
		recipe = {
			materials.dye_yellow, node_fullname
		},
	})
	minetest.register_craft({
		type="shapeless",
		output = mod_prefix..":platform_45_"..nodename.." 2",
		recipe = {
			materials.dye_yellow, node_fullname, node_fullname, node_fullname
		}
	})
	minetest.register_craft({
		type="shapeless",
		output = mod_prefix..":platform_45_low_"..nodename.." 2",
		recipe = { mod_prefix..":platform_45_"..nodename },
	})

	table.insert(prior_platform_materials, node_fullname)
end

-- This function is not needed in the normal case because advtrains will not have created the
-- platforms and their recipes due to missing ingredients.  However, it is included here in case it
-- will be needed for customized workflows that use this mod's API.  Note that any previously
-- registered platform nodes will not be unregistered.  Thus, this function is not symetrical to
-- advtrains_crafting_compatibility_patch.add_recipes_platforms(materials)
--
function advtrains_crafting_compatibility_patch.remove_recipes_platforms()
	-- Remove any previously created platform recipes for advtrains.
	-- These will typically only exist if platform nodes were registered
	-- during auto apply and this is now being called via the API.
	for _, name in pairs(prior_platform_materials) do
		if name ~= "" then
			unregister_craft_platform(name)
		end
	end
	prior_platform_materials = {}
end

function advtrains_crafting_compatibility_patch.add_recipes_platforms(materials)
	if not advtrains_crafting_compatibility_patch.is_valid_materials_table(materials) then
		minetest.debug("["..mod_name.."] Attempted to add crafting recipes for platforms based on an invalid materials table.  Operation aborted")
		return false
	end

	-- For platforms, both the nodes and crafting recipes will need to be created.
	--
	-- If the current game doesn't have "default:stonebrick" and "default:sandstonebrick" then
	-- advtrains will have skipped creating the platforms and their respective recipies.
	--
	if materials.stonebrick ~= "default:stonebrick" then
		register_craft_platform(materials.stonebrick, materials)
	end
	if materials.sandstonebrick ~= "default:sandstonebrick" then
		register_craft_platform(materials.sandstonebrick, materials)
	end

	return true
end

-- ================================================================================================
-- Utility to update all advtrains crafting recipes (subject to mod settings)
-- ================================================================================================

function advtrains_crafting_compatibility_patch.update_crafting_recipes(materials)
	if not advtrains_crafting_compatibility_patch.is_valid_materials_table(materials) then
		minetest.debug("["..mod_name.."] Attempted to update crafting recipes based on an invalid materials table.  Operation aborted")
		return false
	end

	if add_recipes_for_tools then
		if remove_original_recipes then
			advtrains_crafting_compatibility_patch.remove_recipes_tools()
		end
		advtrains_crafting_compatibility_patch.add_recipes_tools(materials)
	end

	if add_recipes_for_track_items then
		if remove_original_recipes then
			advtrains_crafting_compatibility_patch.remove_recipes_track_items()
		end
		advtrains_crafting_compatibility_patch.add_recipes_track_items(materials)
	end

	if add_recipes_for_wagon_parts then
		if remove_original_recipes then
			advtrains_crafting_compatibility_patch.remove_recipes_wagon_parts()
		end
		advtrains_crafting_compatibility_patch.add_recipes_wagon_parts(materials)
	end

	if add_recipes_for_signs_and_signals then
		if remove_original_recipes then
			advtrains_crafting_compatibility_patch.remove_recipes_signs_and_signals()
		end
		advtrains_crafting_compatibility_patch.add_recipes_signs_and_signals(materials)
	end

	if add_recipes_for_platforms then
		advtrains_crafting_compatibility_patch.add_recipes_platforms(materials)
	end

	return true
end

-- ================================================================================================
-- Apply the patch
-- ================================================================================================

if auto_apply then
	local materials = advtrains_crafting_compatibility_patch.get_materials()
	if not materials then
		log_info("No changes were made.")
		return
	end

	log_info("Detected base game: "..materials.base_game)
	if advtrains_crafting_compatibility_patch.update_crafting_recipes(materials) then
		log_info("Auto apply of patch succeeded")
	else
		log_info("Auto apply of patch failed")
	end
else
	-- The only reason to not run in auto_apply mode is because another mod (which should depend on
	-- this mod) will use this mod's API to customize the material substitution mappings.  Note
	-- that when using the API, a mod can optionally bypass some of this mod's settings that limit
	-- the type of recipes that are handled.
	log_info("Not running in auto_apply mode.  (Another mod will presumably use this mod's API.")
	return
end

