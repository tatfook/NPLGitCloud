isStarted = false;

local function activate()
	if(isStarted) then
		return;
	end

	isStarted = true;

	NPL.activate("dgit/dgit.lua", {init=true, server_list={}});
end

NPL.this(activate);