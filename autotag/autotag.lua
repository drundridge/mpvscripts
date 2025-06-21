-- AUTOTAG.LUA --

-- A simple script to make MPV tag media as "played" on your filesystem once a user defined percentage of an episode is watched in MPV.
-- This de facto moves the virtual bookmark seperating watched and unwatched media in your file explorer shown when "group by tags" is enabled, and replaces MAL/AniList and other bloat online bookmark tracking software.

-- The following custom actions can be bound to keys in input.conf to manually tag or untag, in case you skip ahead accidentally or something.
-- (Numpad Divide and Multiply button keybinds used as an example )
-- KP_DIVIDE script-binding autotag/RemoveTag
-- KP_MULTIPLY script-binding autotag/ApplyTag


-- User Configurable Settings --

local var_AutoTag_TagName		= "Watched"								-- Set name of tag to add when watched. "Watched" is reccomended.
local var_AutoTag_TriggerPos	= 85									-- Set watch percentage of media runtime required to trigger tag application. 85 is reccomended.

local var_AutoTag_MinLength		= 60

local array_AutoTag_Whitelist	= {"Anime", "Fiction", "catchup_del"}	-- Restrict tagging to media whose directory paths contains certain text. Use {""} to tag all media watched.
local array_AutoTag_DelList		= {"catchup_del"}						-- Restrict deletion to media whose directory paths contains certain text. Use {""} to delete all media watched, or Use {} to disable deletion.

local var_AutoTag_OSDMessages	= false									-- Show OSD message when tag is updated. Should be turned off.
local var_AutoTag_Logging		= true									-- Enable logging to console


-- Script --

local var_AutoTag_Enabled
local var_AutoTag_DelEnabled
local var_AutoTag_CurrentPos
local var_AutoTag_Temp
local var_AutoTag_Filename
local var_AutoTag_Path

function fn_AutoTag_onPlay()

	var_AutoTag_Enabled = 0
	var_AutoTag_Path = mp.get_property("path")
	var_AutoTag_Filename = mp.get_property("filename")

	for var_AutoTag_Temp = 1, #array_AutoTag_Whitelist do
		if string.find(var_AutoTag_Path, array_AutoTag_Whitelist[var_AutoTag_Temp]) then
			var_AutoTag_Enabled = 1
			break
		end
	end
	if var_AutoTag_Logging then
		if (var_AutoTag_Enabled == 1 ) then
			io.write("[autotag] Tag Pending on " .. var_AutoTag_Filename .. "\n")
		else
			io.write("[autotag] Disabled. Media outside directory whitelist.\n")
		end
	end

end
mp.register_event("start-file", fn_AutoTag_onPlay)


function fn_AutoTag_onEnd()
	if var_AutoTag_Enabled == -1 and string.find(var_AutoTag_Path, array_AutoTag_DelList[1]) then
		os.execute ("rm \"" .. var_AutoTag_Path .. "\"")
		if var_AutoTag_OSDMessages then mp.osd_message("File Deleted") end
		if var_AutoTag_Logging then io.write("\n[autotag] Deleted " .. var_AutoTag_Filename .. "\n") end
	end
end

mp.register_event("end-file", fn_AutoTag_onEnd)

function fn_AutoTag_ApplyTagNoOSD()
	var_AutoTag_Enabled = -1
	mp.set_property_native("file-local-options/save-position-on-quit", "no")
	os.execute ("setfattr -n user.xdg.tags -v \"" .. var_AutoTag_TagName .. "\" -h \"$(readlink -f \"" .. var_AutoTag_Path .. "\")\"")
	if var_AutoTag_Logging then io.write("\n[autotag] Applied " .. var_AutoTag_TagName .. " tag to " .. var_AutoTag_Filename .. "\n") end
end

--Keybind Actions
function fn_AutoTag_ApplyTag()
	mp.osd_message("Applied \"" .. var_AutoTag_TagName .. "\" Tag")
	fn_AutoTag_ApplyTagNoOSD()
end
function fn_AutoTag_RemoveTag()
	mp.osd_message("Removed \"" .. var_AutoTag_TagName .. "\" Tag")
	mp.set_property_native("file-local-options/save-position-on-quit", "yes")
	os.execute ("setfattr -x user.xdg.tags -h \"$(readlink -f \"" .. var_AutoTag_Path .. "\")\"")
	if var_AutoTag_Logging then io.write("\n[autotag] Removed tags from " .. var_AutoTag_Filename .. "\n") end
	fn_AutoTag_onPlay()
end
mp.add_forced_key_binding(nul, 'RemoveTag', fn_AutoTag_RemoveTag)
mp.add_forced_key_binding(nul, 'ApplyTag', fn_AutoTag_ApplyTag)

mp.observe_property(
	"percent-pos", "number",
	function(_, var_AutoTag_CurrentPos)
		if var_AutoTag_CurrentPos == nil then return end
		if (var_AutoTag_Enabled == 1 and var_AutoTag_CurrentPos >= var_AutoTag_TriggerPos - 1) then
			if var_AutoTag_OSDMessages then
				fn_AutoTag_ApplyTag()
			else
				fn_AutoTag_ApplyTagNoOSD()
			end
		end
	end
)
