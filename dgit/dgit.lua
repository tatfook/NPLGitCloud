
NPL.AddPublicFile("dgit/dgit.lua", 1);

function start_server(_port)
	NPL.StartNetServer("0.0.0.0", _port);

	local rts_name = "dgit_server";
	local worker = NPL.CreateRuntimeState(rts_name, 0);
	worker:Start();
	
	log("=====dgit node is now started=========\n\n")
end

function start_client(_ip, _port, _server_list)
	NPL.StartNetServer("0.0.0.0", "0");
	input = input or {};
	
	NPL.AddNPLRuntimeAddress({host=_ip, port=_port, nid="dgit_client"})
	
	local rts_name = "dgit_server";
	while( NPL.activate(string.format("(%s)dgit_client:dgit/dgit.lua", rts_name), {data="from client"}) ~=0 ) do end
end


local function activate()
	if(msg.init) then
		print("isInit");
		start_server("1130");
		if(type(msg.server_list) == "table") then
			for key,ip in msg.server_list do
				start_client(ip, "1130");
			end
		end
	end
end

NPL.this(activate);