--���ŵ�Ӱ
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
local player_name = "test";
local player = Movie.CreateOrGetPlayer(player_name);
player:AddEventListener("movie_start",function(holder,event)
	commonlib.echo("===========start");
end)
player:AddEventListener("movie_update",function(holder,event)
	commonlib.echo("===========update");
	commonlib.echo(event);
	local esc_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_SPACE);
	if(esc_pressed and event.run_time > 1000)then
		player:Clear();
	end	
end)
player:AddEventListener("movie_end",function(holder,event)
	commonlib.echo("===========end");
end)
Movie.DoPlay_File("test","config/Aries/StaticMovies/61HaqiTown_teen_Show2.xml");



--׼���滻��
MotionXmlToTable.PlayCombatMotion

MotionLine ���������� 
@RenderParent:��Ⱦ��parent container
@DisableAnim:��ֹanim
<MotionLine TargetType="Mcml" RenderParent="aaaa" DisableAnim="true"/>