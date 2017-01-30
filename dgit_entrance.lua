isStarted = false;

local function activate()
	if(isStarted) then
		return;
	end

	isStarted = true;

	-- NPL.activate("dgit/dgit.lua", {cmd="init", nid="naomi"});
	-- NPL.activate("dgit/dgit.lua", {});
	NPL.activate("dgit/dgit.lua", {cmd="info"});
end

NPL.this(activate);