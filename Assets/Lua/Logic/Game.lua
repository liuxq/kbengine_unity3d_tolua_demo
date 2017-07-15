Event = require 'events'
require "Dbg"
require "KBEngine"

require "Kbe/Account"
require "Kbe/Avatar"
require "Kbe/Gate"
require "Kbe/Monster"
require "Kbe/NPC"

require "Logic/MoveControl"
require "Logic/GameEntity"
require "Logic/World"
require "Logic/UI"


--管理器--
Game = {};
local this = Game;

local game; 
local transform;
local gameObject;
local WWW = UnityEngine.WWW;


--初始化完成
function Game.OnInitOK()
    World.init();
end
