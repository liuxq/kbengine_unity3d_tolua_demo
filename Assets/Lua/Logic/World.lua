
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
	local playerObj = newObject(obj);
	avatar.renderObj = playerObj;
	playerObj.transform.position = avatar.position;
	--playerObj.transform.direction = avatar.direction;
	MoveControl.playerTransform = playerObj.transform;
	MoveControl.characterControl = playerObj:GetComponent("CharacterController");
	MoveControl.StartUpdate();
	--初始化对象
	World.InitEntity(avatar);

	UI.info("loading scene...(加载场景中...)");
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
		World.set_name( entity , entity.name );
	end
	if entity.direction then
		World.set_direction( entity );
	end
	if entity.position then
		World.set_position( entity );
	end
	if entity.state then
		World.set_state( entity );
	end
end

function World.onLeaveWorld(entity)
	if entity.gameEntity ~= nil then
		entity.gameEntity:Destroy();
	end
	if entity.renderObj ~= nil then
		UnityEngine.Object.Destroy(entity.renderObj);
		entity.renderObj = nil;
	end
end

function World.addSpaceGeometryMapping( respath )

	UI.info("scene(" .. respath .. "), spaceID=" .. KBEngineLua.spaceID);
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
	if entity.renderObj ~= nil then
		entity.gameEntity:UpdateHp();
	end
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
	
end