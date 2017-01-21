local function activate()
	for i=1,table.getn(msg),1
	do
		print(msg[i]);
	end
end
NPL.this(activate);