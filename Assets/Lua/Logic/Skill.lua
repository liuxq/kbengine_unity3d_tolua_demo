
Skill = {
	name = "",
	descr = "",
	id = 0,
	canUseDistMin = 0,
	canUseDistMax = 3,

	displayType = 1,

	skillEffect = "",
	restCoolTimer = 0,

};

function Skill:New( me )
 	me = me or {};
 	setmetatable(me, self);
 	self.__index = self;
 	return me;
end

function Skill:validCast(caster, target)
	local dist = Vector3.Distance(target.position, caster.position);
    if dist > self.canUseDistMax then
        return false;
    end
    return true;
end


function Skill:use(caster, target)
	caster:cellCall({"useTargetSkill", self.id, target.id});
    self.restCoolTimer = 0;
end