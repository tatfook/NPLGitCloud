--[[
Title: 
Author(s): Leio
Date: 2009/11/5
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/HomeLandCommonNode.lua");


����
"Grid" ����
"PlantE" ����ֲ��ֲ��
"OutdoorHouse" ����
"OutdoorOther" ����
	"ChristmasSocks" ʥ������
	"MusicBox" ���ֺ�
����
"Furniture" �Ҿ�
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");

local HomeLandCommonNode = commonlib.inherit(CommonCtrl.Display3D.SceneNode, {
	type = "HomeLandCommonNode",
}, function(o)
	
end)
commonlib.setfield("CommonCtrl.Display3D.HomeLandCommonNode",HomeLandCommonNode);
function HomeLandCommonNode:GetType()
	return self.type;
end
--���ֺе������Ƿ񲥷�
function HomeLandCommonNode:SetMusicBoxPlaying(v)
	self.music_isplaying = v;
end
function HomeLandCommonNode:GetMusicBoxPlaying()
	return self.music_isplaying;
end

--�����Ƿ��иı�
function HomeLandCommonNode:SetPropertyIsChanged(v)
	self.property_is_changed = v;
end
function HomeLandCommonNode:GetPropertyIsChanged()
	return self.property_is_changed;
end
--�������Ե�uid
function HomeLandCommonNode:SetSeedGridNodeUID(uid)
	self.seedGridUID = uid;
end
function HomeLandCommonNode:GetSeedGridNodeUID()
	return self.seedGridUID;
end
--���������item guid
function HomeLandCommonNode:GetGUID()
	return self.item_guid;
end	
function HomeLandCommonNode:SetGUID(guid)
	self.item_guid = guid;
end
--���������item gsid
function HomeLandCommonNode:GetGSID()
	return self.item_gsid;
end	
function HomeLandCommonNode:SetGSID(gsid)
	self.item_gsid = gsid;
end
--���������Զ������
function HomeLandCommonNode:GetBean()
	return self.bean;
end	
function HomeLandCommonNode:SetBean(bean)
	self.bean = bean;
end
----��ֲ������������ GridInfo=\"20091015T084400.953125-295|1\"
--function HomeLandCommonNode:SetGrid(gridInfo)
	--self.gridInfo = gridInfo;
--end
----�ڽ����԰��ʱ�� ��������ȡ ֲ������Ļ���uid
--function HomeLandCommonNode:GetGrid()
	--return self.gridInfo;
--end
--������ģ�������� ���������ĸ����ⷿ�ݵ�
function HomeLandCommonNode:SetOutdoorNodeUID(uid)
	self.belongto_outdoor_uid = uid;
end
function HomeLandCommonNode:GetOutdoorNodeUID()
	return self.belongto_outdoor_uid;
end
--@params args:һЩ�ɱ�Ĳ���
function HomeLandCommonNode:ClassToMcml(args)
	local params = self:GetEntityParams();
	
	if(args and args.origin)then
		--�Ӿ�������ת��Ϊ�������
		params.x = params.x - args.origin.x;
		params.y = params.y - args.origin.y;
		params.z = params.z - args.origin.z;
	end
	local k,v;
	local result = "";
	for k,v in pairs(params) do
			if(type(v)~="table")then
				if(k == "x" or k == "y" or k == "z" or k == "facing" or k == "scaling")then
					if(type(v) == "number") then
						if(v == math.floor(v)) then
							v = string.format("%d", v);
						else
							v = string.format("%.2f", v);
						end
					end
				end
				v = tostring(v) or "";
				local s = string.format('%s="%s" ',k,v);
				result = result .. s;
			end
	end
	local title = self.type;
	local HomeLandObj = string.format('%s="%s" ',"HomeLandObj",title);
	result =  result..HomeLandObj;
	--local gridInfo = self.gridInfo or "";
	local gridInfo = "";
	--����й����Ļ���
	--�����������ʽ��GridInfo=\"20091015T084400.953125-295|1\"
	if(self.seedGridUID)then
		gridInfo = self.seedGridUID.."|"..1;--���ڵ�һ��������λ����
	end
	----��ֲ������������ GridInfo=\"20091015T084400.953125-295|1\"
	gridInfo = string.format('%s="%s" ',"GridInfo",gridInfo or "");
	result =  result..gridInfo;
		
	--�����ĸ����ⷿ�ݵ�
	local belongto_outdoor_uid = "";
	belongto_outdoor_uid = string.format('%s="%s" ',"belongto_outdoor_uid",self.belongto_outdoor_uid or "");
	result =  result..belongto_outdoor_uid;
	
	--��Ʒϵͳ��guid
	local guid = string.format('%s="%s" ',"guid",self.item_guid or "");
	result =  result..guid;
	--��Ʒϵͳ��gsid
	local gsid = string.format('%s="%s" ',"gsid",self.item_gsid or "");
	result =  result..gsid;
	
	--���ֺе������Ƿ񲥷�
	local music_isplaying = "";
	if(self.music_isplaying)then
		music_isplaying = "true";
	else
		music_isplaying = "false";
	end
	local music_isplaying = string.format('%s="%s" ',"music_isplaying",music_isplaying);
	result =  result..music_isplaying;
	
	result =  string.format('<HomeLandObj_B %s/>',result);
	return result;
end
