
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
	
	-- while( NPL.activate(string.format("(%s):dgit/dgit.lua", _nid), {data="from client"}) ~=0 ) do end
end


-- key: nid, value: ip, port, avail, repos
server_list = {};
myNid = "";
repo_dir = "";
-- msg.cmd "init" | "update" | "info" | "callback" | "git" | "dgit" | "git_cmd"
-- msg.server.ip 	only in init
-- msg.server.port 	only in init
-- msg.server.nid	only in init
-- msg.nid 			in init (self nid) and callback (sender's nid)
-- msg.ip 			only in init
-- msg.port 		only in init
-- msg.repo_dir		only in init
-- msg.server_list  only in update 
-- 					a list, key is nid, value is a table containing ip, port
-- msg.ret 			only in callback
-- msg.original_cmd	only in callback
-- msg.callback		in info | git | dgit, the script is going to call it backwith 
--  				a cmd of callback and a ret of return value
-- msg.git_param	in git | dgit
-- msg.git_cmd		in git | dgit
local function activate()
	if(msg.cmd == "init") then
		print("isInit");
		start_server("1130", msg.nid);
		if(type(msg.server) == "table") then
			start_client(msg.server.ip, msg.server.port, msg.server.nid);
		end

		myNid = msg.nid;
		repo_dir = msg.repo_dir;
		server_list[msg.nid] = {ip = msg.ip, 
										port = msg.port};	
		NPL.activate("dgit/dgit.lua", {cmd="info"});

		if(NPL.activate(string.format("(%s):dgit/dgit.lua", msg.server.nid), 
						{cmd="info",callback=string.format("(%s):dgit/dgit.lua", myNid)}) ==0) then
			server_list[msg.server.nid] = {ip = msg.server.ip, 
										port = msg.server.port};
			NPL.activate(string.format("(%s):dgit/dgit.lua", msg.server.nid), 
				{cmd="update", server_list = server_list});
		end
								
	elseif(msg.cmd == "update") then
		for key,value in msg.server_list do
			if(server_list[key]) then
				if(server_list[key] ~= value) then
					server_list[key] = value;
				end
			else
				start_client(msg.server.ip, msg.server.port, msg.server.nid);

				if(NPL.activate(string.format("(%s):dgit/dgit.lua", key), 
						{cmd="info",callback=string.format("(%s):dgit/dgit.lua", myNid)})==0) then
					server_list[key] = value;
					NPL.activate(string.format("(%s):dgit/dgit.lua", key), {cmd="update",server_list=server_list});
				end
			end
		end
	elseif(msg.cmd == "info") then
		local fs_info = {} -- Get data from df
		local f = io.popen("LC_ALL=C df -P -B 512 .")
		for line in f:lines() do -- Match: (size) (used)(avail)(use%) (mount)
			local s     = string.match(line, "^.-[%s]([%d]+)")
			local u,a,p = string.match(line, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)%%")
			local m     = string.match(line, "%%[%s]([%p%w]+)")
			if u and m then -- Handle 1st line and broken regexp
		        fs_info[m] = {}
		        fs_info[m]["size"] = s
		        fs_info[m]["used"] = u
		        fs_info[m]["avail"] = a
		        fs_info[m]["used_p"]  = tonumber(p)
		        fs_info[m]["avail_p"] = 100 - tonumber(p)
			end
			print(m);
		end
    	f:close();

    	local largest = 0;
    	for m,info in fs_info do
    		if(tonumber(info["avail"]) > largest) then
    			largest = tonumber(info["avail"]);
    		end
    	end
    	server_list[myNid].avail = largest;


    	local repos = {};
    	f = io.popen(string.format("LC_ALL=C ls -d %s/*/*/", repo_dir));

		for token in string.gmatch(f:read("*all"), "[^%s]+") do
			local p_in = io.popen("git log -1 --pretty=format:\"%at\"");
			local timestamp = tonumber(p_in:line());
			p_in:close();
   			repos[token] = timestamp;
		end
		f:close();

		server_list[myNid].repos = repos;

		if(msg.callback) then
    		NPL.activate(string.format(msg.callback), 
    		{cmd="callback",original_cmd="info",nid=myNid,info={avail=largest,repos=repos}});
    	end

    elseif(msg.cmd == "callback") then
    	if(msg.original_cmd == "info") then
    		local largest = 0;
    		server_list[msg.nid] = msg.info;

    	elseif(msg.original_cmd == "git_cmd") then
    		-- to do, update all nodes
    		-- to do, link up with api
    	end

    elseif(msg.cmd == "dgit") then
    	if(msg.git_cmd == "repoInit") then
	    	local largest = {};
	    	local count = 0;
	    	for server_nid,server_info in server_list do
	    		if(count < 3) then
	    			largest[server_nid] = server_list[server_nid];
	    		end

	    		for largest_nid,largest_info in largest do
	    			if(tonumber(largest_info.avail) < tonumber(server_info.avail)) then
	    				largest[largest_nid] = nil;
	    				largest[server_nid] = server_list[server_nid];
	    			end
	    		end
	    	end

	    	for largest_nid, largest_info in largest do
	    		NPL.activate(string.format("(%s):dgit/dgit.lua", largest_nid), 
	    			{cmd="git", git_cmd=msg.git_cmd, 
	    			callback=string.format("(%s):dgit/dgit.lua", myNid), 
	    			git_param=msg.git_param});
	    	end
	    else
	    	for server_nid,server_info in server_list do
	    		for repo_name,commit in server_info.repos do
	    			if(repo_name == msg.git_param[1]) then
	    				NPL.activate(string.format("(%s):dgit/dgit.lua", server_nid), 
	    				{cmd="git", git_cmd=msg.git_cmd, 
	    				callback=string.format("(%s):dgit/dgit.lua", myNid), 
	    				git_param=msg.git_param});
	    			end
	    		end
	    	end
	    end
	elseif(msg.cmd == "git") then
		NPL.activate("git_related/GitcorePlugin.dll", 
			{cmd="git_cmd",git_cmd=msg.git_cmd,callback=msg.callback,payload=msg.git_param});

	-- else
	-- 	if(msg.data) then
	-- 		print(msg.data);
	-- 	else
	-- 		start_client("127.0.0.1", "1130", "naomi");
	-- 	end
	end

end

NPL.this(activate);