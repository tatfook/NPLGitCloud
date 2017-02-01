--[[
Title: 
Author(s): Leio
Date: 2009/11/5
use the lib:
Ŀǰֻ����֧��һ�� �����
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/SeedGridNode.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/HomeLandCommonNode.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
local SeedGridNode = commonlib.inherit(CommonCtrl.Display3D.HomeLandCommonNode, {
	type = "Grid",
}, function(o)
	o.tag = {
		grids = { x = 0, y = 0, z = 0, bind_uid = "", loaded = false, },
	}
end)

commonlib.setfield("CommonCtrl.Display3D.SeedGridNode",SeedGridNode);
--�ڴ���ʵ��֮ǰ
function SeedGridNode:BeforeAttach()

end
--�ڴ���ʵ��֮��
function SeedGridNode:AfterAttach()
	CommonCtrl.AddControl(self.uid, self);
	local entity = self:GetEntity();
	if(entity)then
		entity:GetAttributeObject():SetField("On_AssetLoaded", string.format(";CommonCtrl.Display3D.SeedGridNode.WaitForAssetLoaded('%s');",self.uid))
	end
end
--������ʵ��֮ǰ
function SeedGridNode:BeforeDetach()

end
--������ʵ��֮��
function SeedGridNode:AfterDetach()

end
--��ȡ���ӱ�ռ�õ����
function SeedGridNode:GetGridInfo()
	if(self.tag and self.tag.grids)then
		return self.tag.grids;
	end
end
--�󶨸��ӵ�λ��
--���bind_uid = nil or "" ȡ����
function SeedGridNode:SetGridInfo(index,bind_uid)
	bind_uid = bind_uid or "";
	local grids = self:GetGridInfo();
	if(grids)then
		grids.bind_uid = bind_uid;
		self:SnapToGrid();
	end	
end
--�������ļ�����ɣ���¼������λ����Ϣ
function SeedGridNode.WaitForAssetLoaded(sName)
	local self = CommonCtrl.GetControl(sName);
	if(self)then
		local grids = self:GetGridInfo();
		local pos_x,pos_y,pos_z = self:GetPosition();
		local entity = self:GetEntity();
		if(entity)then
			local nXRefCount = entity:GetXRefScriptCount();
			if(nXRefCount < 1)then return end
			local x,y,z = entity:GetXRefScriptPosition(0);
			x = x - pos_x;--��¼�������
			y = y - pos_y;
			z = z - pos_z;
			grids.x = x;
			grids.y = y;
			grids.z = z;
			grids.loaded = true;--��Ǽ��سɹ�
			
			self:SnapToGrid();
		end
	end
end
--����λ��
function SeedGridNode:SnapToGrid()
	local grids = self:GetGridInfo();
	local root_node = self:GetRootNode();
	if(grids and root_node)then
		local loaded = grids.loaded;
		--��������û�м����� ����
		if(not loaded)then return end
		local pos_x,pos_y,pos_z = self:GetPosition();
		local x = grids.x + pos_x;
		local y = grids.y + pos_y;
		local z = grids.z + pos_z;
		local bind_uid = grids.bind_uid;
		if(bind_uid and bind_uid ~= "" and x and y and z)then
			local node = root_node:GetChildByUID(bind_uid);
			if(node)then
				node:SetPosition(x,y,z);
			end
		end
	end
end
--�Ƿ��Ѿ�������һ��node
--����� ������
function SeedGridNode:HasLinkedNode()
	local grids = self:GetGridInfo();
	local root_node = self:GetRootNode();
	if(grids and root_node)then
		local bind_uid = grids.bind_uid;
		if(bind_uid and bind_uid ~= "")then
			local node = root_node:GetChildByUID(bind_uid);
			return node;
		end
	end
end
