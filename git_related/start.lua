local function activate()
	NPL.activate("GitcorePlugin.dll", {cmd="getContent",callback="/mnt/hgfs/NPLGitCloud/git_related/printer.lua", payload={"value1","value2","value3"}});
end
NPL.this(activate);