NPL.load("(gl)script/apps/WebServer/WebServer.lua");
WebServer:Start("www/", "0.0.0.0", 8181);

NPL.this(function() end);
