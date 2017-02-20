-- NPL.load("../github_api/script/ide/System/os/GetUrl.lua");
NPL.load("(gl)script/ide/System/System.lua");

isStarted = false;

local function activate() 
	if(isStarted) then
		return;
	end
	isStarted = true;
	System.os.GetUrl({url="http://bot.whatismyipaddress.com", method="GET"}, function(err, msg, data)
		print("fuck this shit");
		echo(err);
		echo(msg);
		echo(data);
	end);

	print("ok");
end

NPL.this(activate);
