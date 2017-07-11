require "Logic/CameraFollow"
require "Logic/SkillControl"
require "Logic/GameEntity"

World = {
};

local convertRad2Angle = 360 / (Mathf.PI * 2);

function newObject(prefab)
  	return UnityEngine.Object.Instantiate(prefab);
end

function World.init()
	Event.AddListener("onAvatarEnterWorld", World.onAvatarEnterWorld);
	Event.AddListener("onEnterWorld", World.onEnterWorld);
	Event.AddListener("onLeaveWorld", World.onLeaveWorld);
	Event.AddListener("addSpaceGeometryMapping", World.addSpaceGeometryMapping);

	Event.AddListener("set_position", World.set_position);
	Event.AddListener("set_direction", World.set_direction);
	Event.AddListener("set_name", World.set_name);
	Event.AddListener("set_state", World.set_state);
	Event.AddListener("set_HP", World.set_HP);
	Event.AddListener("set_HP_Max", World.set_HP_Max);
	Event.AddListener("updatePosition", World.updatePosition);
	Event.AddListener("recvDamage", World.recvDamage)

end

function World.onAvatarEnterWorld( avatar )
	if not avatar:isPlayer() then
		return;
	end

	local obj = UnityEngine.Resources.Load("player");
	local go = newObject(obj);
	avatar.renderObj = go;
	go.transform.position = avatar.position;
	--go.transform.direction = avatar.direction;
	CameraFollow.target = go.transform;
	CameraFollow.ResetView();
	CameraFollow.FollowUpdate();
	
	--初始化对象
	World.InitEntity(avatar);

	--初始化角色技能控制
	SkillControl.Init(avatar);

	UpdateBeat:Add(SkillControl.Update);
	
end

function World.onEnterWorld( entity )
	if entity:isPlayer() then 
		return;
	end

	local obj = newObject(UnityEngine.Resources.Load("entity"));
	entity.renderObj = obj;
	entity.renderObj.transform.position = entity.position;
	World.InitEntity(entity);

end

function World.InitEntity( entity )
	entity.gameEntity = GameEntity:New();
	entity.gameEntity:Init(entity);		
	if entity.name then
		World.set_name( entity , entity.name )
	end
	if entity.direction then
		World.set_direction( entity )
	end
	if entity.position then
		World.set_position( entity )
	end
end

function World.onLeaveWorld(entity)
	if entity.gameEntity ~= nil then
		entity.gameEntity:Destroy();
	end
	if entity.renderObj ~= nil then
		destroy(entity.renderObj);
		entity.renderObj = nil;
	end
end

function World.addSpaceGeometryMapping( path )

	local obj = newObject(UnityEngine.Resources.Load("terrain"));

end

function World.set_position( entity )
	entity.gameEntity:SetPosition(entity.position);
end

function World.set_direction( entity )
	entity.gameEntity.m_destDirection = Vector3.New();
	entity.gameEntity.m_destDirection.x = entity.direction.y * convertRad2Angle;
	entity.gameEntity.m_destDirection.y = entity.direction.z * convertRad2Angle;
	entity.gameEntity.m_destDirection.z = entity.direction.x * convertRad2Angle;
end

function World.set_name( entity , v)
	if entity.gameEntity then
		entity.gameEntity:SetName(v);
	end
end

function World.set_state( entity , v)
	if entity.gameEntity then
		entity.gameEntity:OnState(v);
	end
	if entity:isPlayer() then
		if(v == 1) then
			UI.showReliveGUI = true;
		else
			UI.showReliveGUI = false;
		end
	end
end

function World.set_HP( entity , v)
	
end

function World.set_HP_Max( entity , v)
	if entity.renderObj ~= nil then
		entity.gameEntity:UpdateHp();
	end
end

function World.updatePosition( entity )
	entity.gameEntity.m_destPosition = entity.position;
end

function World.recvDamage( receiver, attacker, skillID, damageType, damage )
	local sk = SkillBox.Get(skillID);
    if (sk ~= nil) then
        local renderObj = attacker.renderObj;
        renderObj:GetComponent("Animator"):Play("Punch");

        if attacker:isPlayer() then   
        	local dir = receiver.position - attacker.position; 
            renderObj.transform:LookAt(Vector3.New(renderObj.transform.position.x + dir.x, renderObj.transform.position.y, renderObj.transform.position.z + dir.z));
        end

        --显示技能效果
        sk:displaySkill(attacker, receiver);
    end
end