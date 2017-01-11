NPL.load("(gl)script/apps/WebServer/WebServer.lua");

print("Start NPL API server");
WebServer:Start("www/", "0.0.0.0", 8181);

NPL.this(function() end);
