-------------------------�����ļ���ʽ
script/ide/MotionEx/Motion.xml
-------------------------MotionPlayer.lua ����ʵ���˶������ŵĻ���
--��������
MotionPlayer:Play()
--����ֹͣ����ǰ��
MotionPlayer:Stop()
--����ֹͣ�������
MotionPlayer:End()
--������ͣ
MotionPlayer:Pause()
--������������
MotionPlayer:Resume()
--������ת��ָ����ʱ�䣬��λ����
MotionPlayer:GoToTime(time)
--������ת��ָ����ʱ��time_str = "00:00:10.5"
MotionPlayer:GoToByTimeStr(time_str)
-------------------------MotionLineBase.lua:�����ߵĻ���
�̳��������Ҫ��д�ķ�����
--@param root_time:���룬MotionPlayer���е���ʱ��
--@param local_time:���룬MotionLineBase��ǰ���е�ʱ��
--@param root_max_time:���룬MotionLineBase���е���ʱ��
MotionLineBase:__GoToTime(root_time,local_time,local_max_time)

MotionLineBase:__Play()
MotionLineBase:__Reset()
MotionLineBase:__Stop()
MotionLineBase:__End()
-------------------------MotionLine.lua:�̳���MotionLineBase.lua��ʵ���˾���ؼ�֡�������߼�
һ��MotionLine ���ж��KeyFrame��ɣ���ʱ���С��������
ÿ��KeyFrame�����Զ����Լ��ĸ������ԣ�keyFrame = { KeyTime = "00:00:01.5", FrameType = "", x = 0, y = 0 ...};
����ԭ��
--��ȡ��ǰʱ���µĹؼ�֡
local curKeyFrame,nextKeyFrame = self:GetRuntimeKeyFrame(localtime);
--���û�е����һ֡
if(curKeyFrame and nextKeyFrame)then
	--������һ�ؼ�֡������
	local frametype = nextKeyFrame["FrameType"];
	if(frametype == "None" or frametype == "none"  or frametype == ""  or frametype == nil)then
		--����ǿգ������㣬ֱ�ӷ���
		return value of curKeyFrame
	else
		--������Ч�Ĳ�ֵ
		local change_value = nextKeyFrame.x - curKeyFrame.y;
		���ؼ�����
	end
else
	--���е����һ֡
	if(curKeyFrame)then
		return value of curKeyFrame
	end
end
-------------------------MotionRender.lua:��Ծ��嶯�����͵ĸ���
-------------------------MotionTypes.lua:��ֵ���㹫ʽ
