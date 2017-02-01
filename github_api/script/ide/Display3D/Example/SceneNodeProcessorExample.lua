--[[
Title: 
Author(s): Leio
Date: 2009/8/17
use the lib:
��Viewģʽ��
���ѡ������

��Editģʽ��
��һ�ε����ѡ������
�ڶ��ε�������������������
�����ε�����������
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/Example/SceneNodeProcessorExample.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Display3D/SceneNodeProcessor.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");

local SceneNodeProcessorExample = commonlib.inherit(CommonCtrl.Display3D.SceneNodeProcessor, {
	selectedNode = nil,--��ѡ�е����� 
	editMode = "view", --view or edit
	arrowRootNode = nil,--��ͷ��ʾ�����㳡��
	dragRootNode = nil,--��ק��ʾ�����㳡��
	dragContainer = nil,--��ק�ĸ�������������dragRootNode����
	isDrag = false,--�Ƿ�������ק
	dragLastX = 0,--��ק�ƶ�����һ��λ��
	dragLastY = 0,
	dragLastZ = 0,
	-- ���ѡ������壬����Ĵ��� ��editģʽ����Ч
	clickNum = 0,
	readyDragNode = nil,--��clickNum = 1 ��׼���ƶ���node
}, function(o)
		--------------------
		--��ͷ��ʾ�����㳡��
		--------------------
		local scene = CommonCtrl.Display3D.SceneManager:new{
			--type = "miniscene",
		};
		local rootNode = CommonCtrl.Display3D.SceneNode:new{
			root_scene = scene,
		} 
		o.arrowRootNode = rootNode;
		--------------------
		--��ק��ʾ�����㳡��
		--------------------
		local scene = CommonCtrl.Display3D.SceneManager:new{
			--type = "miniscene",
		};
		local rootNode = CommonCtrl.Display3D.SceneNode:new{
			root_scene = scene,
		} 
		o.dragRootNode = rootNode;
end)

commonlib.setfield("CommonCtrl.Display3D.SceneNodeProcessorExample",SceneNodeProcessorExample);

function SceneNodeProcessorExample:DoMouseDown(event)
	--commonlib.echo("===========DoMouseDown");

end
function SceneNodeProcessorExample:DoMouseUp(event)
	--commonlib.echo("===========DoMouseUp");
	
end
function SceneNodeProcessorExample:DoMouseMove(event)
	--commonlib.echo("===========DoMouseMove");

end
--[[
event.msg = {
  IsComboKeyPressed=false,
  IsMouseDown=false,
  MouseDragDist={ x=0, y=0 },
  dragDist=269,
  lastMouseDown={ x=782, y=488 },
  lastMouseUpButton="right",
  lastMouseUpTime=6699.6712684631,
  lastMouseUp_x=789,
  lastMouseUp_y=496,
  mouse_button="right",
  mouse_x=559,
  mouse_y=196,
  virtual_key=242,
  wndName="mouse_move" 
}
--]]
function SceneNodeProcessorExample:DoMouseOver(event)
	if(event and event.msg)then
		local msg = event.msg;
		--if(msg.mouse_button == "left")then
			if(not self.isDrag)then
				self:ShowTip(event);
			end
		--end
	end
end
function SceneNodeProcessorExample:DoMouseOut(event)
	if(event and event.msg)then
		local msg = event.msg;
		--if(msg.mouse_button == "left")then
			if(not self.isDrag)then
				self:HideTip(event);
			end
		--end
	end
end
function SceneNodeProcessorExample:DoChildSelected(event)
	if(event and event.msg)then
		local msg = event.msg;
		if(msg.mouse_button == "left")then
			if(not self.isDrag)then
				self:SelectedNode(event);
			end
		end
	end
end
function SceneNodeProcessorExample:DoChildUnSelected(event)
	if(event and event.msg)then
		local msg = event.msg;
		if(msg.mouse_button == "left")then
			if(not self.isDrag)then
				self:UnSelectedNode(event);
			end
		end
	end
end
function SceneNodeProcessorExample:DoMouseDown_Stage(event)
	--commonlib.echo("===========DoMouseDown_Stage");
end
function SceneNodeProcessorExample:DoMouseUp_Stage(event)
	if(event and event.msg)then
		local msg = event.msg;
		if(msg.mouse_button == "left")then
			if(self.editMode == "edit")then
				--�����������ק�����
				if(not self.isDrag)then
					local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
					if(selectedNode)then
						--��һ�ε��
						if(self.clickNum == 0)then
							self.clickNum = self.clickNum + 1;
							--��¼���������
							self.readyDragNode = selectedNode;
						elseif(self.clickNum == 1)then
							--�ڶ��ε�� ������ͬһ������
							if(selectedNode == self.readyDragNode)then
								self.clickNum = 2;
								self:StartDrag();
							else
								--�������ͬһ������
								--��¼���������
								self.readyDragNode = selectedNode;
							end
						end
					else
						self.clickNum = 0;
						self.readyDragNode = nil;
					end
				else
					self:StopDrag();
					self.clickNum = 0;
					self.readyDragNode = nil;
					self:UnSelected();
				end
			end
		end
	end
end
function SceneNodeProcessorExample:DoMouseMove_Stage(event)
	--commonlib.echo("===========DoMouseMove_Stage");
	if(self.isDrag and self.dragContainer)then
		local pt = ParaScene.MousePick(70, "point");
		if(pt:IsValid())then
			local x,y,z = pt:GetPosition();
			local dx = x - self.dragLastX;
			local dy = y - self.dragLastY;
			local dz = z - self.dragLastZ;
			self:UpdateMirrorDragNodePos(dx,dy,dz);
			self.dragLastX,self.dragLastY,self.dragLastZ = x,y,z;
		end
	end
end
--������ק�����λ��
function SceneNodeProcessorExample:UpdateMirrorDragNodePos(dx,dy,dz)
	if(self.dragContainer)then
		local x,y,z = self.dragContainer:GetPosition();
		x = x + dx;
		y = y + 0;
		z = z + dz;
		self.dragContainer:SetPosition(x,y,z);
	end
end
--ѡ��һ������
function SceneNodeProcessorExample:SelectedNode(event)
	if(not event)then return end
	local target = event.currentTarget;
	if(target)then
		local type = target:GetType();
		if(type == "HomeLandCommonNode")then
			self:ShowSelected(target,true);
			--��ס��ѡ�е�����
			self:SetSelectedNode(target);
		elseif(type == "Grid")then
			local node = target:HasLinkedNode()
			if(node)then
				--���seedgrid�й�����node,��ʾnode��ѡ��
				self:ShowSelected(node,true);
				--��ס��ѡ�е����� �ǹ�����node
				self:SetSelectedNode(node);
			else
				--��������״̬����ʾ��ͷ
				if(self.editMode == "view")then
					--���û�� ��ʾseedgrid����ļ�ͷ��ʾ
					self:ShowArrow(target,true)
				else
					--��ʾѡ�л���
					self:ShowSelected(target,true)
				end
				self:SetSelectedNode(target);
			end
		end
	end
end
--ȡ��ѡ��һ������
function SceneNodeProcessorExample:UnSelectedNode(event)
	if(not event)then return end
	local target = event.currentTarget;
	if(target)then
		local type = target:GetType();
		if(type == "HomeLandCommonNode")then
			self:ShowSelected(target,false);
		elseif(type == "Grid")then
			--��������״̬��
			if(self.editMode == "view")then
				--���ؼ�ͷ
				self:ShowArrow(target,false);
			else
				--ȡ��ѡ�л���
				self:ShowSelected(target,false)
			end
			--���seedgrid�й�����node
			local node = target:HasLinkedNode()
			if(node)then
				self:ShowSelected(node,false);
			end
		end
	end
	self:SetSelectedNode(nil);
end
--��ʾ��ʾ
function SceneNodeProcessorExample:ShowTip(event)
	if(not event)then return end
	local target = event.currentTarget;
	if(target)then
		local type = target:GetType();
		if(type == "HomeLandCommonNode")then
			if(target ~= self.selectedNode)then
				self:ShowSelected(target,true);
			end
		elseif(type == "Grid")then
			local node = target:HasLinkedNode()
			if(node)then
				if(node ~= self.selectedNode)then
					--���seedgrid�й�����node,��ʾnode��ѡ��
					self:ShowSelected(node,true);
				end
			else
				--��������״̬����ʾ��ͷ
				if(self.editMode == "view")then
					if(target ~= self.selectedNode)then
						--���û�� ��ʾseedgrid����ļ�ͷ��ʾ
						self:ShowArrow(target,true)
					end
				else
					if(target ~= self.selectedNode)then
						--��ʾѡ�л���
						self:ShowSelected(target,true)
					end
				end
			end
		end
	end
end
--������ʾ
function SceneNodeProcessorExample:HideTip(event)
	if(not event)then return end
	local target = event.currentTarget;
	if(target)then
		local type = target:GetType();
		if(type == "HomeLandCommonNode")then
			if(target ~= self.selectedNode)then
				self:ShowSelected(target,false);
			end
		elseif(type == "Grid")then
			--��������״̬��
			if(self.editMode == "view")then
				if(target ~= self.selectedNode)then
					--���ؼ�ͷ
					self:ShowArrow(target,false);
				end
			else
				if(target ~= self.selectedNode)then
					--��ʾѡ�л���
					self:ShowSelected(target,false)
				end
			end
			--���seedgrid�й�����node
			local node = target:HasLinkedNode()
			if(node)then
				if(node ~= self.selectedNode)then
					self:ShowSelected(node,false);
				end
			end
		end
	end
end

--�Ƿ���ʾ��������ļ�ͷ
function SceneNodeProcessorExample:ShowArrow(seedGridNode,bShow)
	if(not seedGridNode)then return end
	if(self.arrowRootNode)then
		self.arrowRootNode:Detach();
		if(bShow)then
			local x,y,z = seedGridNode:GetPosition();
			local arrow = CommonCtrl.Display3D.SceneNode:new{
				x = x,
				y = y,
				z = z,
				assetfile = "model/06props/v3/headarrow.x",
			};
			self.arrowRootNode:AddChild(arrow);
		end	
	end
end
--��ѡ�л��Ե�ǰ���£�����һ��node�󣬸���ѡ�еĶ���Ϊnode
function SceneNodeProcessorExample:SnapAndSelected()
	if(not self.selectedNode)then return end
	local target = self.selectedNode;
	local type = target:GetType();
	if(type == "Grid")then
		self:ShowArrow(target,false)
		local node = target:HasLinkedNode()
		if(node)then
			--���seedgrid�й�����node,��ʾnode��ѡ��
			self:ShowSelected(node,true);
			--��ס��ѡ�е����� �ǹ�����node
			self:SetSelectedNode(node);
		end
	end
end
--ȡ��ѡ���Ѿ�ѡ�е�node
function SceneNodeProcessorExample:UnSelected()
	local target = self.selectedNode;
	if(target)then
		local type = target:GetType();
		if(type == "HomeLandCommonNode")then
			self:ShowSelected(target,false);
		elseif(type == "Grid")then
			--���ؼ�ͷ
			self:ShowArrow(target,false);
		end
	end
	self:SetSelectedNode(nil);
end
--��¼��ѡ�е�node�����node=nil ȡ��ѡ��
function SceneNodeProcessorExample:SetSelectedNode(node)
	self.selectedNode = node;
	--TODO:���������
end
--����ѡ�е�node ���������Ļ���
function SceneNodeProcessorExample:GetSelectedNodeAndLinkedNode()
	if(self.selectedNode and self.canvas and self.canvas.rootNode)then
		local selectedNodeUID  = self.selectedNode:GetUID();
		local type = self.selectedNode:GetType();
		if(type == "HomeLandCommonNode")then
			local linkedUID = self.selectedNode:GetSeedGridNodeUID();
			local linkedNode;
			if(linkedUID and linkedUID ~= selectedNodeUID)then
				linkedNode = self.canvas.rootNode:GetChildByUID(linkedUID);
				return self.selectedNode,linkedNode;
			end
		end
		return self.selectedNode;
	end
end
function SceneNodeProcessorExample:ShowSelected(node,bShow)
	if(node)then
		local id = node:GetEntityID();
		local obj = ParaScene.GetObject(id);
		if(obj and obj:IsValid())then
			if(bShow)then
				obj:GetAttributeObject():SetField("showboundingbox", true);
				--ParaSelection.AddObject(obj,1);
			else
				obj:GetAttributeObject():SetField("showboundingbox", false);
				--ParaSelection.AddObject(obj,-1);
			end
		end
	end
end
--���ñ༭ģʽ "view" or "edit"
function SceneNodeProcessorExample:SetEditMode(mode)
	self.editMode = mode;
end
function SceneNodeProcessorExample:GetEditMode()
	return self.editMode;
end
--facing delta
function SceneNodeProcessorExample:SetFacingDelta(facing)
	if(facing and self.editMode == "edit")then
		local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
		if(selectedNode)then
			selectedNode:SetFacingDelta(facing);
		end
		if(linkedNode)then
			linkedNode:SetFacingDelta(facing);
		end
	end
end
--position delta
function SceneNodeProcessorExample:SetPositionDelta(dx,dy,dz)
	if(dx and dy and dz and self.editMode == "edit")then
		local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
		if(selectedNode)then
			selectedNode:SetPositionDelta(dx,dy,dz);
		end
		if(linkedNode)then
			linkedNode:SetPositionDelta(dx,dy,dz);
		end
	end
end
--��self.clickNum = 1ʱ ֱ����קѡ�е�ͬһ������
function SceneNodeProcessorExample:DirectlyDragSelectedNode()
	local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
	if(self.clickNum == 1 and selectedNode == self.readyDragNode)then
		self.clickNum = 2;
		self:StartDrag();
	end
end
--��ʼ��ק
function SceneNodeProcessorExample:StartDrag()
	if(not self.dragRootNode)then return end
	self.dragRootNode:Detach();
	local container = CommonCtrl.Display3D.SceneNode:new{
		node_type = "container",
		x = 0,
		y = 0,
		z = 0,
		visible = true,
	};
	self.dragRootNode:AddChild(container);
	
	local mirror_1;
	local mirror_2;
	local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
	if(selectedNode)then
		local mirror_1 = selectedNode:Clone();
		container:AddChild(mirror_1);
		self:ShowSelected(selectedNode,false);
		selectedNode:SetVisible(false);
		
		--��selectedNode������Ϊ׼
		self.isDrag = true;
		self.dragLastX,self.dragLastY,self.dragLastZ = selectedNode:GetPosition();
	end
	if(linkedNode)then
		local mirror_2 = linkedNode:Clone();
		container:AddChild(mirror_2);
		
		linkedNode:SetVisible(false);
	end
	--��¼��ק�ĸ�����
	self.dragContainer = container;
end
--ֹͣ��ק
function SceneNodeProcessorExample:StopDrag()
	if(not self.dragRootNode or not self.dragContainer)then return end
	local selectedNode,linkedNode = self:GetSelectedNodeAndLinkedNode();
	self:UpdateNodePosition(selectedNode,1);
	self:UpdateNodePosition(linkedNode,2);
	self.isDrag = false;
	self.dragRootNode:Detach();
end
--ͨ�������λ�ø�����ʵnode������
function SceneNodeProcessorExample:UpdateNodePosition(node,mirrorNodeIndex)
	if(not node or not mirrorNodeIndex or not self.dragContainer)then return end
	local mirror_node = self.dragContainer:GetChild(mirrorNodeIndex);
	if(mirror_node)then
		local renderParams = mirror_node:GetRenderParams();
		if(renderParams)then
			local x,y,z = renderParams.x,renderParams.y,renderParams.z;
			node:SetPosition(x,y,z);
			node:SetVisible(true);
		end
	end
end