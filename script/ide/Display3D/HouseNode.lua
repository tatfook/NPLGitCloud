--[[
Title: 
Author(s): Leio
Date: 2009/11/5
use the lib:
ÿ�����ݶ������������ ���cometo_point_position �� ���غ��λ�� comeback_point_position
����ģ�ͷ����֣�
����ģ��type = "OutdoorHouse"
����ģ��type = "IndoorHouse"

ÿһ������ģ�Ͱ�һ������ģ��
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/HouseNode.lua");

NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");

local sceneManager = CommonCtrl.Display3D.SceneManager:new{
		--type = "miniscene" --"scene" or "miniscene"
	};
local rootNode = CommonCtrl.Display3D.SceneNode:new{
	root_scene = sceneManager,
}

function gotoFunc(node)
	commonlib.echo("on hit!");
	if(not node or not node.linked_node)then return end
	local x,y,z = node.linked_node:GetAbsComeBackPosition();
	commonlib.echo({x,y,z});
	if(x and y and z)then
		Map3DSystem.SendMessage_game({type = Map3DSystem.msg.GAME_TELEPORT_PLAYER, x= x, y = y, z = z});
	end
end
local x,y,z = ParaScene.GetPlayer():GetPosition();
local outdoor_node = CommonCtrl.Display3D.HouseNode:new{
	x = x,
	y = y,
	z = z,
	--assetfile = "model/01building/v5/01house/PoliceStation/Indoor.x",
	assetfile = "model/01building/v5/01house/PoliceStation/PoliceStation.x",
	type = "OutdoorHouse",
	ReadyGoFunc = gotoFunc,
};
rootNode:AddChild(outdoor_node);
local indoor_node = CommonCtrl.Display3D.HouseNode:new{
	x = x,
	y = y + 10,
	z = z,
	assetfile = "model/01building/v5/01house/PoliceStation/Indoor.x",
	type = "IndoorHouse",
	ReadyGoFunc = gotoFunc,
};
rootNode:AddChild(indoor_node);
--����node
outdoor_node:SetLinkedHouse(indoor_node);
indoor_node:SetLinkedHouse(outdoor_node);

-------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
NPL.load("(gl)script/ide/Display3D/HomeLandCommonNode.lua");
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local HouseNode = commonlib.inherit(CommonCtrl.Display3D.HomeLandCommonNode, {
	type = "OutdoorHouse",--Ĭ��Ϊ����ģ�� --OutdoorHouse or IndoorHouse
	loaded = false,--������Ƿ�loaded
	cometo_point_position = nil,--��Ҫ���͵Ĳ�����λ��
	comeback_point_position = nil,--���غ��λ��
	linked_node = nil,--����ģ�� ����<---->����
	miniRootNode = nil,
	default_openstate = true,--�ڲ����������Ĭ���Ƿ�򿪴��͵����
	
	--�¼�
	ReadyGoFunc = nil,--׼������
	--global
	--��¼�����ķ��� 
	registerNodes = {
	
	},
	global_timer = nil,
	--defaultArrow = "model/06props/v3/headarrow.x",
	defaultArrow = "model/07effect/v5/ChuanSongDoor/ChuanSongDoor.x",
	
}, function(o)
	local sceneManager = CommonCtrl.Display3D.SceneManager:new{
		--type = "miniscene" --"scene" or "miniscene"
	};
	local rootNode = CommonCtrl.Display3D.SceneNode:new{
		root_scene = sceneManager,
	}
	o.miniRootNode = rootNode;
end)

commonlib.setfield("CommonCtrl.Display3D.HouseNode",HouseNode);
function HouseNode:EnabledAssetLoaded()
	CommonCtrl.AddControl(self.uid, self);
	local entity = self:GetEntity();
	commonlib.echo("==============AfterAttach");
	commonlib.echo(self.type);
	commonlib.echo(self:GetParams());
	if(entity)then
		entity:GetAttributeObject():SetField("On_AssetLoaded", string.format(";CommonCtrl.Display3D.HouseNode.WaitForAssetLoaded('%s');",self.uid))
	end
	
	if(not CommonCtrl.Display3D.HouseNode.global_timer)then
		local global_timer = commonlib.Timer:new{
			callbackFunc = HouseNode.TimerUpdate,
		}
		global_timer:Change(0, 1000)
		CommonCtrl.Display3D.HouseNode.global_timer = global_timer;
	end
end
--�ڴ���ʵ��֮ǰ
function HouseNode:BeforeAttach()

end
--�ڴ���ʵ��֮��
function HouseNode:AfterAttach()
	local entity = self:GetEntity();
	if(entity)then
		entity:SetPhysicsGroup(1);
	end
end
--������ʵ��֮ǰ
function HouseNode:BeforeDetach()

end
--������ʵ��֮��
function HouseNode:AfterDetach()

end
--���¼��ز���������
function HouseNode:ReloadLoadPoint()
	local entity = self:GetEntity();
	if(entity)then
		local pos_x,pos_y,pos_z = self:GetPosition();
		local _x,_y,_z = entity:GetXRefScriptPosition(0);
		local node = self.miniRootNode:GetChild(1);
		local x = _x - pos_x;--��¼�������
		local y = _y - pos_y;
		local z = _z - pos_z;
		if(x and y and z and node)then
			node:SetPosition(_x,_y,_z);
			
			--��Ҫ���͵Ĳ�����λ��
			self.cometo_point_position = {
				x = x,
				y = y,
				z = z,
			}
			
		end
		local _x,_y,_z = entity:GetXRefScriptPosition(1);
		local x = _x - pos_x;--��¼�������
		local y = _y - pos_y;
		local z = _z - pos_z;
		if(x and y and z and node)then
			--���غ��λ��
			self.comeback_point_position = {
				x = x,
				y = y,
				z = z,
			}
		end
	end
end
--������������ɣ���¼������λ����Ϣ
function HouseNode.WaitForAssetLoaded(sName)
	local self = CommonCtrl.GetControl(sName);
	if(self)then
		local pos_x,pos_y,pos_z = self:GetPosition();
		local entity = self:GetEntity();
		if(entity)then
			commonlib.echo("==============AfterAssetLoaded");
			local nXRefCount = entity:GetXRefScriptCount();
			if(nXRefCount < 2)then return end
			local x,y,z = entity:GetXRefScriptPosition(0);
			x = x - pos_x;--��¼�������
			y = y - pos_y;
			z = z - pos_z;
			--��Ҫ���͵Ĳ�����λ��
			self.cometo_point_position = {
				x = x,
				y = y,
				z = z,
			}
			commonlib.echo("====cometo_point_position");
			commonlib.echo(self.cometo_point_position);
			----����
			--if(self.type == "OutdoorHouse")then
				--self.cometo_point_position = {
					--x = x + 5,
					--y = y,
					--z = z + 5,
				--}
			--end
			local x,y,z = entity:GetXRefScriptPosition(1);
			x = x - pos_x;--��¼�������
			y = y - pos_y;
			z = z - pos_z;
			--���غ��λ��
			self.comeback_point_position = {
				x = x,
				y = y,
				z = z,
			}
			commonlib.echo("====comeback_point_position");
			commonlib.echo(self.comeback_point_position);
			--�������سɹ�
			self.loaded = true;
			
			--���Ӽ�ͷ��ʾ
			if(self.miniRootNode)then
				local x,y,z = self:GetAbsCometoPosition();
				local node = CommonCtrl.Display3D.SceneNode:new{
					x = x,
					y = y,
					z = z,
					assetfile = self.defaultArrow,
				};
				commonlib.echo("=======house arrow");
				commonlib.echo(node:GetEntityParams());
				self.miniRootNode:AddChild(node);
			end
			--�򿪼���
			if(self.default_openstate)then
				self:OpenDoor();
			else
				self:CloseDoor();
			end
			commonlib.echo("==============loaded");
			commonlib.echo(self.type);
		end
	end
end
--���ü�ͷ�Ƿ���ʾ
function HouseNode:ShowArrowTip(bShow)
	if(self.miniRootNode)then
		self.miniRootNode:SetVisible(bShow);
		
		local node = self.miniRootNode:GetChild(1);
		if(node)then
			local x,y,z = self:GetAbsCometoPosition();
			node:SetPosition(x,y,z);
			local facing = self:GetFacing();
			node:SetFacing(facing);
		end
	end
end
--���� ����--���� ģ��
function HouseNode:GetLinkedHouse()
	return self.linked_node;
end
function HouseNode:SetLinkedHouse(node)
	self.linked_node = node;
end
--�򿪴�����
function HouseNode:OpenDoor()
	local uid = self:GetUID();
	self.registerNodes[uid] = self;
	self:ShowArrowTip(true)
	self:ReloadLoadPoint();
end
--�رմ�����
function HouseNode:CloseDoor()
	local uid = self:GetUID();
	self.registerNodes[uid] = "";
	self:ShowArrowTip(false)
end
--��ȡ���͵�ľ�������
--node = self or node = self.linked_node
function HouseNode:GetAbsCometoPosition(node)
	if(not node)then 
		node = self;
	end
	local pos_x,pos_y,pos_z = node:GetPosition();
	local point_position = node.cometo_point_position;
	if(point_position)then
		pos_x = pos_x + point_position.x;
		pos_y = pos_y + point_position.y;
		pos_z = pos_z + point_position.z;
	end
	return pos_x,pos_y,pos_z;
end
--��ȡ���ص�ľ�������
--node = self or node = self.linked_node
function HouseNode:GetAbsComeBackPosition(node)
	if(not node)then 
		node = self;
	end
	local pos_x,pos_y,pos_z = node:GetPosition();
	local point_position = node.comeback_point_position;
	if(point_position)then
		pos_x = pos_x + point_position.x;
		pos_y = pos_y + point_position.y;
		pos_z = pos_z + point_position.z;
	end
	return pos_x,pos_y,pos_z;
end
--timer �ĸ���
function HouseNode.TimerUpdate()
	local self = HouseNode;
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	local point = {x = x, y = y, z = z};
	if(self.registerNodes)then
		local uid,node;
		for uid,node in pairs(self.registerNodes) do
			if(node and node ~= "" and node.cometo_point_position)then
				local pos_x,pos_y,pos_z = node:GetAbsCometoPosition();
				local box = {
					pos_x = pos_x,
					pos_y = pos_y,
					pos_z = pos_z,
					obb_x = 4,
					obb_y = 4,
					obb_z = 4,
				}
				
				local result = CommonCtrl.Display.Util.ObjectsCreator.Contains(point,box,true);
				if(result)then
					if(node.ReadyGoFunc)then
						node.ReadyGoFunc(node);
					end
					return
				end
			end
		end
	end
end
function HouseNode.ClearAndResetGlobalData()
	--ֹͣ������ڵļ���
	if(HouseNode.global_timer)then
		HouseNode.global_timer:Change();
	end
	--�����һ�εļ�¼
	if(HouseNode.registerNodes)then
		HouseNode.registerNodes = {};
	end
	if(HouseNode.global_timer)then
		HouseNode.global_timer:Change(0, 1000);
	end
end