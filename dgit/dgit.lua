
NPL.AddPublicFile("dgit/dgit.lua", 1);

function start_server(_port, _nid)
	NPL.StartNetServer("0.0.0.0", _port);

	local rts_name = _nid;
	local worker = NPL.CreateRuntimeState(rts_name, 0);
	worker:Start();
	
	log("=====dgit node is now started=========\n\n")
end

function start_client(_ip, _port, _nid)
	NPL.StartNetServer("0.0.0.0", "0");
	input = input or {};
	
	NPL.AddNPLRuntimeAddress({host=_ip, port=_port, nid=_nid})
	
	while( NPL.activate(string.format("(%s):dgit/dgit.lua", _nid), {data="from client"}) ~=0 ) do end
end


server_list = {};
-- msg.cmd "init" | "update" | "git"
-- msg.server.ip 	only in init
-- msg.server.port 	only in init
-- msg.server.nid	only in init
-- msg.nid 			only in init
-- msg.ip 			only in init
-- msg.port 		only in init
-- msg.server_list  only in update 
-- 					a list, key is nid, value is a table containing ip, port
local function activate()
	if(msg.cmd == "init") then
		print("isInit");
		start_server("1130", msg.nid);
		if(type(msg.server) == "table") then
			start_client(msg.server.ip, msg.server.port, msg.server.nid);
		end
		server_list[msg.server.nid] = {ip = msg.server.ip, 
										port = msg.server.port};
		server_list[msg.nid] = {ip = msg.ip, 
										port = msg.port};							
	elseif(msg.cmd == "update") then
		local alreadyKnown = true;
		for key,value in msg.server_list do
			if(server_list[key]) then
			else
				start_client(msg.server.ip, msg.server.port, msg.server.nid);
				server_list[key].ip = value.ip;
				server_list[key].port = value.port;
				alreadyKnown = false;
			end
		end
		if(alreadyKnown == false) then
			for key,value in server_list do
				if(NPL.activate(string.format("(%s):dgit/dgit.lua", key), {cmd="update",server_list=server_list})~=0) then
					server_list[key] = nil;
				end
			end
		end
	elseif(msg.cmd == "git") then
		
	else
		if(msg.data) then
			print(msg.data);
		else
			start_client("127.0.0.1", "1130", "naomi");
		end
	end

end

NPL.this(activate);