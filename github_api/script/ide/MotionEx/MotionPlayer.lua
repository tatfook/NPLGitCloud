--[[
Title: MotionPlayer
Author(s): Leio
Date: 2010/06/11
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionPlayer.lua");
NPL.load("(gl)script/ide/MotionEx/MotionLineBase.lua");
local motionPlayer = MotionEx.MotionPlayer:new{
	space = 200,
};
motionPlayer:AddEventListener("play",function()
	commonlib.echo("play");
end,{});
motionPlayer:AddEventListener("stop",function()
	commonlib.echo("stop");
end,{});
motionPlayer:AddEventListener("end",function()
	commonlib.echo("end");
end,{});
motionPlayer:AddEventListener("update",function(funcHolder,event)
	commonlib.echo("update");
	commonlib.echo(event.time);
end,{});

local motionLine = MotionEx.MotionLineBase:new{
	name = "a",
	space = 30,
	repeatCnt = 1,
}
motionPlayer:AddMotionLine(motionLine);
--local motionLine = MotionEx.MotionLineBase:new{
	--name = "b",
	--space = 1000,
--}
--motionPlayer:AddMotionLine(motionLine);
--local motionLine = MotionEx.MotionLineBase:new{
	--name = "c",
	--space = 800,
--}
--motionPlayer:AddMotionLine(motionLine);
motionPlayer.space = 200;
motionPlayer:Play();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
local LOG = LOG;
local MotionPlayer = commonlib.inherit({
	at_endpoint = true,--�Զ��������Ĭ�� ��ֹͣ����� false��ֹͣ����ǰ
	duration = 10,--ˢ��Ƶ�� ����
	space = 0,--���ŵ���ʱ�� ���룬���ֵ���鲻Ҫֱ�Ӹ��ģ��������children�Զ�����
	esc_key = false,--esc��ֹͣ��������
}, commonlib.gettable("MotionEx.MotionPlayer"));
function MotionPlayer:ctor()
	self.play_timer = commonlib.Timer:new({callbackFunc = function(timer)
		self:TimeUpdate(timer);
	end})
	self.ispause = false;
	self.elapsed_time = 0;--����
	self.motion_lines = {};
	self.events = commonlib.EventDispatcher:new();
end
--�ӵ�һ֡��ʼ����
function MotionPlayer:Play()
	local k,line;
	for k,line in ipairs(self.motion_lines) do
		line:Reset();
	end
	self:Reset();
	self:DispatchEvent({
		type="play",
		sender = self,
	});
end
--���¿�ʼ
function MotionPlayer:Reset()
	self.ispause = false;
	self.elapsed_time = 0;--����
	self.play_timer:Change(0,self.duration);	
end
--ֹͣ����ǰ
function MotionPlayer:Stop()
	self:Reset();
	self.play_timer:Change();	
	self:GoToTime(0);
	self:DispatchEvent({
		type="stop",
		sender = self,
	});
end
--ֹͣ�����
function MotionPlayer:End()
	self:Reset();
	self.play_timer:Change();
	self:GoToTime(self.space);
	self:DispatchEvent({
		type="end",
		sender = self,
	});
end
--��ͣ
function MotionPlayer:Pause()
	self.ispause = true;
end
--����ͣλ�ü�������
function MotionPlayer:Resume()
	self.ispause = false;
end
--����
function MotionPlayer:TimeUpdate(timer)
	if(self.ispause)then return end
	local duration = self.duration;
	if(timer)then
		duration = timer:GetDelta(200);
	end
	if(self.elapsed_time < self.space)then
		self:GoToTime(self.elapsed_time,duration);
		self.elapsed_time = self.elapsed_time + duration;
	else
		if(self.at_endpoint)then
			self:End();
		else
			self:GoToTime(self.space);
			self:Stop();
		end
	end
	if(self.esc_key)then
		local esc_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_SPACE);
		if(esc_pressed)then
			self:Stop();
		end	
	end
end
--��ȡ���е�ʱ��
function MotionPlayer:GetRuntime()
	return self.elapsed_time;
end
function MotionPlayer:GoToByTimeStr(time_str)
	if(not time_str)then return end
	local time = commonlib.timehelp.TimeStrToMill(time_str);
	self:GoToTime(time);
end
--��ת���ƶ�ʱ�� ���� ��������/��λ�����ʱ���
local update_msg_template = {
	type="update",
}
function MotionPlayer:GoToTime(time,delta)
	if(not time or time > self.space or time < 0)then return end
	self.elapsed_time = time;
	local k,line;
	for k,line in ipairs(self.motion_lines) do
		line:GoToTime(time,delta);
	end
	update_msg_template.sender = self;
	update_msg_template.time = time;
	self:DispatchEvent(update_msg_template);
end
--��ȡ�����ʱ��
function MotionPlayer:GetSpace(bForce)
	if(bForce)then
		local line,space = self:GetMaxMotionLineSpace();
		self.space = space;
	end
	return self.space;
end
--��ȡ�����ʱ���motionline
function MotionPlayer:GetMaxMotionLineSpace()
	local k,line;
	local space = 0;
	local find_line;
	for k,line in ipairs(self.motion_lines) do
		local line_space = line:GetSpace();
		if(line_space > space)then
			space = line_space;
			find_line = line;
		end
	end
	return find_line,space;
end
--�������
function MotionPlayer:Clear()
	self.motion_lines = {};
	self:Reset();
	self.play_timer:Change();
end
--����һ��MotionLine
function MotionPlayer:AddMotionLines(motionlines)
	if(not motionlines)then return end
	local k,line;
	for k,line in ipairs(motionlines) do
		self:AddMotionLine(line,true);
	end
	local line,space = self:GetMaxMotionLineSpace();
	self.space = space;
end
--����һ��MotionLine
function MotionPlayer:AddMotionLine(motionline,bNotUpdate)
	if(not motionline)then return end
	motionline:SetParent(self);
	table.insert(self.motion_lines,motionline);
	if(not bNotUpdate)then
		local line,space = self:GetMaxMotionLineSpace();
		self.space = space;
	end
end
function MotionPlayer:AddEventListener(type,func,funcHolder)
	self.events:AddEventListener(type,func,funcHolder);
end
function MotionPlayer:RemoveEventListener(type)
	self.events:RemoveEventListener(type);
end
function MotionPlayer:DispatchEvent(event, ...)
	self.events:DispatchEvent(event, ...);
end

function MotionPlayer:HasEventListener(type)
	return self.events:HasEventListener(type);
end