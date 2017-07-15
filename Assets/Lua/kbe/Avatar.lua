require "Kbe/Interface/GameObject"
require "Logic/SkillBox"
require "Logic/Skill"

KBEngineLua.Avatar = {
	itemDict = {},
    equipItemDict = {},
};

KBEngineLua.Avatar = KBEngineLua.GameObject:New(KBEngineLua.Avatar);--继承

function KBEngineLua.Avatar:New(me) 
    me = me or {};
    setmetatable(me, self);
    self.__index = self;
    return me;
end

function KBEngineLua.Avatar:__init__( )
	if self:isPlayer() then
        Event.AddListener("relive", self.relive);
        Event.AddListener("updatePlayer", self.updatePlayer);
    end
end

function KBEngineLua.Avatar:updatePlayer(x, y, z, yaw)
    self.position.x = x;
    self.position.y = y;
    self.position.z = z;

    self.direction.z = yaw;
end

function KBEngineLua.Avatar:onEnterWorld()
    if self:isPlayer() then
        Event.Brocast("onAvatarEnterWorld", self);
        SkillBox.Pull();
    end
end

function KBEngineLua.Avatar:relive(type)
    self:cellCall({"relive", type});
end


function KBEngineLua.Avatar:useTargetSkill(skillID, target)        
    local skill = SkillBox.Get(skillID);
    if (skill == nil) then
        return false;
    end

    if target == nil then
        return false;
    end

    if (skill:validCast(self, target)) then         
        skill:use(self, target);
        return true;
    end
    
    return false;
end

-------client method-----------------------------------

function KBEngineLua.Avatar:onAddSkill(skillID)        
    log(self.className .. "::onAddSkill(" .. skillID .. ")");

    local skill = Skill:New();
    skill.id = skillID;
    skill.name = skillID .. " ";
    if skillID == 1 then
        skill.displayType = 1;
        skill.canUseDistMax = 20;
        skill.skillEffect = "skill1";
        skill.name = "魔法球";
    elseif skillID == 1000101 then
        skill.displayType = 1;
        skill.canUseDistMax = 20;
        skill.skillEffect = "skill2";
        skill.name = "火球";
    elseif skillID == 2000101 then
        skill.displayType = 1;
        skill.canUseDistMax = 20;
        skill.skillEffect = "skill3";
        skill.name = "治疗";
    elseif skillID == 3000101 then
        skill.displayType = 0;
        skill.canUseDistMax = 20;
        skill.skillEffect = "skill4";
        skill.name = "斩击";
    elseif skillID == 4000101 then
        skill.displayType = 0;
        skill.canUseDistMax = 20;
        skill.skillEffect = "skill5";
        skill.name = "挥击";
    elseif skillID == 5000101 then
        skill.displayType = 0;
        skill.canUseDistMax = 20;
        skill.skillEffect = "skill6";
        skill.name = "吸血";
    elseif skillID == 6000101 then
        skill.displayType = 0;
        skill.canUseDistMax = 20;
        skill.skillEffect = "skill6";
        skill.name = "吸血";
    end;

    SkillBox.Add(skill);

end

function KBEngineLua.Avatar:onRemoveSkill(skillID)        
    log(className .. "::onRemoveSkill(" .. skillID .. ")");
    SkillBox.Remove(skillID);
end