
NPL.load("(gl)script/ide/System/System.lua");

local charset = {}

function string.random(length)
  math.randomseed(os.time())

  if length > 0 then
    return string.random(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end


function dgit_interface_init(callback)

	local file = io.open("/opt/NPLGitCloud/my.nid", "r");

	for i = 48,  57 do table.insert(charset, string.char(i)) end
	for i = 65,  90 do table.insert(charset, string.char(i)) end
	for i = 97, 122 do table.insert(charset, string.char(i)) end

	if(file == nil) then
		my_nid = file:read();
	else
		my_nid = string.random(20);
		file = io.open("/opt/NPLGitCloud/my.nid", "w");
		if(file == nil) then
			print("permission denied");
			return
		end

		file:write(my_nid);
	end

	System.os.GetUrl("bot.whatismyipaddress.com", function(err, msg, data) 
						if(msg.rcode ~= 200) then
							print("Cannot connected to internet.");
							callback("No Internet");
							return;
						end
						my_ip = data; 

						NPL.activate("./dgit.lua", {cmd="init",
							-- TODO server info
							nid=my_nid,
							ip=my_ip,
							port=1130,
							repo_dir="/opt/NPLGitCloud",
						});

						callback(nil);
					end);
end

function dgit_interface_getContent(param, callback)
	NPL.activate("./dgit.lua", {cmd="dgit", git_cmd="getContent", git_param=param, callback = callback});
end

function dgit_interface_repoInit(param, callback)
	NPL.activate("./dgit.lua", {cmd="dgit", git_cmd="repoInit", git_param=param, callback = callback});
end

function dgit_interface_updateFile(param, callback)
	NPL.activate("./dgit.lua", {cmd="dgit", git_cmd="updateFile", git_param=param, callback = callback});
end

function dgit_interface_addFile(param, callback)
	NPL.activate("./dgit.lua", {cmd="dgit", git_cmd="addFile", git_param=param, callback = callback});
end

function dgit_interface_deleteFile(param, callback)
	NPL.activate("./dgit.lua", {cmd="dgit", git_cmd="deleteFile", git_param=param, callback = callback});
end

function dgit_interface_deleteRepo(param, callback)
	NPL.activate("./dgit.lua", {cmd="dgit", git_cmd="deleteRepo", git_param=param, callback = callback});
end

function dgit_interface_traverseTree(param, callback)
	NPL.activate("./dgit.lua", {cmd="dgit", git_cmd="traverseTree", git_param=param, callback = callback});
end

local function activate()
	dgit_interface_init(function(err)
	end);

end

NPL.this(activate);
