GameEntity = {
	entityName = nil,
	entity = nil,
	m_destDirection = nil,
	m_destPosition = nil,
	m_position = nil,
	m_eulerAngles = nil,

	m_rotation = nil,

};

function GameEntity:New( me )
 	me = me or {};
 	setmetatable(me, self);
 	self.__index = self;
 	return me;
end

function GameEntity:SetPosition( pos )
	self.m_position = pos:Clone();
	if self.entity.renderObj then
		self.entity.renderObj.transform.position = self.m_position;
	end
end

function GameEntity:SetEulerAngles( angles )
	self.m_eulerAngles = angles:Clone();
	if self.entity.renderObj then
		self.entity.renderObj.transform.eulerAngles = self.m_eulerAngles;
	end
end


function GameEntity:Init( entity )
	self.entity = entity;
	self:StartUpdate();
	self.headName = entity.renderObj.transform:Find("Canvas/name"):GetComponent("Text");
	self.headHp = entity.renderObj.transform:Find("Canvas/hp"):GetComponent("Text");
	self.headNameCanvasTrans = entity.renderObj.transform:Find("Canvas").transform;
	self.material = entity.renderObj.transform:FindChild("Graphics"):GetComponent("MeshRenderer").material;
	self.cameraTransform = UnityEngine.Camera.main.transform;
end

function GameEntity:SetName( name )
	--绘制头顶文字
	self.entityName = name;
    if self.headName ~= nil then
        self.headName.text = self.entityName;
    end
end

function GameEntity:UpdateHp( )
	--绘制头顶hp

    if self.headHp ~= nil then
        self.headHp.text = self.entity.HP.."/"..self.entity.HP_Max;
    end
end

function GameEntity:OnState( v )
	--状态
	if (v == 3) then
		if(self.entity:isPlayer()) then
			self.material.color = Color.green;
		else
			self.material.color = Color.red;
		end
	elseif (v == 0) then
		if(self.entity:isPlayer()) then
			self.material.color = Color.blue;
		else
			self.material.color = Color.white;
		end
	elseif (v == 1) then
		self.material.color = Color.black;
	end
end

function GameEntity:StartUpdate()
	FixedUpdateBeat:Add(self.FixedUpdate, self);
	UpdateBeat:Add(self.Update, self);
end

function GameEntity:Update()
	if self.headNameCanvasTrans then
		self.headNameCanvasTrans.rotation = self.cameraTransform.rotation;
	end

	if self.entity:isPlayer() then
		local go = self.entity.renderObj;
		Event.Brocast("updatePlayer", self.entity, go.transform.position.x,
	            go.transform.position.y, go.transform.position.z, go.transform.rotation.eulerAngles.y);   
	end

	--更新位置和方向
	if self.m_destDirection then
		if not self.m_eulerAngles then
			self:SetEulerAngles( self.m_destDirection );
		end

		if Vector3.Distance(self.m_eulerAngles, self.m_destDirection) > 0.0004 then
			self:SetEulerAngles( self.m_destDirection );
		end
	end

	if self.m_destPosition then
		if not self.m_position then
			self:SetPosition(self.m_destPosition);
		end

		local dist = Vector3.Distance(self.m_position, self.m_destPosition)
		if dist > 0.01 then
			--self:SetPosition(Vector3.Lerp(self.m_position, self.m_destPosition, 1));--100 * UnityEngine.Time.deltaTime));
			self:SetPosition(self.m_destPosition);
		end
	end

end

function GameEntity:FixedUpdate()
	
end

function GameEntity:Destroy()
	FixedUpdateBeat:Remove(self.FixedUpdate, self);
	UpdateBeat:Remove(self.Update, self);
	self.entity = nil;
	self.headName = nil;
	self.headNameCanvasTrans = nil;
	self.cameraTransform = nil;
end