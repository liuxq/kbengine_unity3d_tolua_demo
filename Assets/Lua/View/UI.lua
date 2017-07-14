
Application = UnityEngine.Application;
SceneManager = UnityEngine.SceneManagement.SceneManager;
GUI = UnityEngine.GUI;
Rect = UnityEngine.Rect;
Screen = UnityEngine.Screen;

UI = {

	ui_state = 0,
	stringAccount = "",
	stringPasswd = "",
	labelMsg = "",
	labelColor = Color.green,
	ui_avatarList = nil,
	
	stringAvatarName = "",
	startCreateAvatar = false,

	selAvatarDBID = 0,
	showReliveGUI = false,
	
	startRelogin = false,
};

local this = UI;

function UI.Start() 
	this.installEvents();
	SceneManager.LoadScene("login");
end

function UI.installEvents()
	--common
	Event.AddListener("onKicked", UI.onKicked);
	Event.AddListener("onDisconnected", UI.onDisconnected);
	Event.AddListener("onConnectionState", UI.onConnectionState);
	
	--login
	Event.AddListener("onCreateAccountResult", UI.onCreateAccountResult);
	Event.AddListener("onLoginFailed", UI.onLoginFailed);
	Event.AddListener("onVersionNotMatch", UI.onVersionNotMatch);
	Event.AddListener("onScriptVersionNotMatch", UI.onScriptVersionNotMatch);
	Event.AddListener("onLoginBaseappFailed", UI.onLoginBaseappFailed);
	Event.AddListener("onLoginSuccessfully", UI.onLoginSuccessfully);
	Event.AddListener("onReloginBaseappFailed", UI.onReloginBaseappFailed);
	Event.AddListener("onReloginBaseappSuccessfully", UI.onReloginBaseappSuccessfully);
	Event.AddListener("onLoginBaseapp", UI.onLoginBaseapp);
	Event.AddListener("Loginapp_importClientMessages", UI.Loginapp_importClientMessages);
	Event.AddListener("Baseapp_importClientMessages", UI.Baseapp_importClientMessages);
	Event.AddListener("Baseapp_importClientEntityDef", UI.Baseapp_importClientEntityDef);
	
	--select-avatars(register by scripts)
	Event.AddListener("onReqAvatarList", UI.onReqAvatarList);
	Event.AddListener("onCreateAvatarResult", UI.onCreateAvatarResult);
	Event.AddListener("onRemoveAvatar", UI.onRemoveAvatar);

end

function UI.OnDestroy()
	Event.deregisterOut(this);
end

--Update is called once per framefunction UI.Update ()
function UI.Update()
    if (Input.GetKeyUp(KeyCode.Space))then
		log("KeyCode.Space");
		--Event.fireIn("jump");
    end
end
function UI.onSelAvatarUI()
	
	if (this.startCreateAvatar == false and GUI.Button(Rect.New(Screen.width / 2 - 100, Screen.height - 40, 200, 30), "RemoveAvatar(删除角色)")) then
		if(this.selAvatarDBID == 0) then
			logError("Please select a Avatar!(请选择角色!)");
		else
			this.info("Please wait...(请稍后...)");
			
			if(this.ui_avatarList ~= nil) then
				local avatarinfo = this.ui_avatarList[this.selAvatarDBID];

				local p = KBEngineLua.player();
				if p ~= nil then
					p:reqRemoveAvatar(avatarinfo["name"]);
				end
			end
		end
    end

	if (this.startCreateAvatar == false and GUI.Button(Rect.New(Screen.width / 2 - 100, Screen.height - 75, 200, 30), "CreateAvatar(创建角色)")) then
		this.startCreateAvatar = not this.startCreateAvatar;
	end

    if (this.startCreateAvatar == false and GUI.Button(Rect.New(Screen.width / 2 - 100, Screen.height - 110, 200, 30), "EnterGame(进入游戏)")) then
    	if(this.selAvatarDBID == 0) then
    		logError("Please select a Avatar!(请选择角色!)");
    	else
    		this.info("Please wait...(请稍后...)");
    		
    		local p = KBEngineLua.player();
			if p ~= nil then
				p:selectAvatarGame(this.selAvatarDBID);
			end

			SceneManager.LoadScene("world");
			ui_state = 2;
		end
    end
	
	if(this.startCreateAvatar) then
        if (GUI.Button(Rect.New(Screen.width / 2 - 100, Screen.height - 40, 200, 30), "CreateAvatar-OK(创建完成)")) then
        	if(#this.stringAvatarName > 1)then
	        	this.startCreateAvatar = not this.startCreateAvatar;
	        	local p = KBEngineLua.player();
				if p ~= nil then
					p:reqCreateAvatar(1, this.stringAvatarName);
				end
				--Event.fireIn("reqCreateAvatar", (Byte)1, this.stringAvatarName); temp
			else
				logError("avatar name is nil(角色名称为空)!");
			end
        end
        
        this.stringAvatarName = GUI.TextField(Rect.New(Screen.width / 2 - 100, Screen.height - 75, 200, 30), this.stringAvatarName, 20);
	end
	
	if(this.ui_avatarList ~= nil) then
		local idx = 0;

		for dbid,v in pairs(this.ui_avatarList)
		do
			local info = this.ui_avatarList[dbid];
		--	Byte roleType = (Byte)info["roleType"];
			local name = info["name"];
		--	UInt16 level = (UInt16)info["level"];
			local idbid = info["dbid"];

			idx = idx + 1;
			
			local color = GUI.contentColor;
			if(this.selAvatarDBID == idbid) then
				GUI.contentColor = Color.red;
			end
			
			if (GUI.Button(Rect.New(Screen.width / 2 - 100, Screen.height / 2 + 120 - 35 * idx, 200, 30), name)) then
				log("selAvatar:" .. name);
				this.selAvatarDBID = idbid;
			end
			
			GUI.contentColor = color;
		end
	else
		if(KBEngineLua.entity_type == "Account") then
			local account = KBEngineLua.player();
			if(account ~= nil) then
				this.ui_avatarList = account.avatars;
			end
		end
	end
end

function UI.onLoginUI()
	if(GUI.Button(Rect.New(Screen.width / 2 - 100, Screen.height / 2 + 30, 200, 30), "Login(登陆)")) then  
    	log("this.stringAccount:" .. this.stringAccount);
    	log("this.stringPasswd:" .. this.stringPasswd);
    	
		if(#this.stringAccount > 0 and #this.stringPasswd > 5) then
			this.login();
		else
			logError("account or password is error, length < 6!(账号或者密码错误，长度必须大于5!)");
		end
    end

    if (GUI.Button(Rect.New(Screen.width / 2 - 100, Screen.height / 2 + 70, 200, 30), "CreateAccount(注册账号)")) then  
		log("this.stringAccount:" .. this.stringAccount);
		log("this.stringPasswd:" .. this.stringPasswd);

		if(#this.stringAccount > 0 and #this.stringPasswd > 5) then
			this.createAccount();
		else
			logError("account or password is error, length < 6!(账号或者密码错误，长度必须大于5!)");
		end
    end
    
	this.stringAccount = GUI.TextField(Rect.New (Screen.width / 2 - 100, Screen.height / 2 - 50, 200, 30), this.stringAccount, 20);
	this.stringPasswd = GUI.PasswordField(Rect.New (Screen.width / 2 - 100, Screen.height / 2 - 10, 200, 30), this.stringPasswd, 69);
end

function UI.onWorldUI()
	if(this.showReliveGUI) then
		if(GUI.Button(Rect.New(Screen.width / 2 - 100, Screen.height / 2, 200, 30), "Relive(复活)")) then
			local p = KBEngineLua.player();
			if p ~= nil then
				p:relive(1);
			end
		end
	end
	
	local obj = UnityEngine.GameObject.Find("player(Clone)");
	if(obj ~= nil) then
		GUI.Label(Rect.New((Screen.width / 2) - 100, 20, 400, 100), "position=" .. obj.transform.position["x"]..obj.transform.position["y"]..obj.transform.position["z"]); 
	end
end

function UI.OnGUI()  

	if(ui_state == 1) then
		this.onSelAvatarUI();
	elseif(ui_state == 2) then
		this.onWorldUI();
	else
		this.onLoginUI();
	end
		
	if(KBEngineLua ~= nil and KBEngineLua.serverVersion ~= "" 
		and KBEngineLua.serverVersion ~= KBEngineLua.clientVersion) then
		this.labelColor = Color.red;
		this.labelMsg = "version not match(curr=" .. KBEngineLua.clientVersion .. ", srv=" .. KBEngineLua.serverVersion .. " )(版本不匹配)";
	elseif(KBEngineLua ~= nil and KBEngineLua.serverScriptVersion ~= "" 
		and KBEngineLua.serverScriptVersion ~= KBEngineLua.clientScriptVersion) then
		this.labelColor = Color.red;
		this.labelMsg = "scriptVersion not match(curr=" .. KBEngineLua.clientScriptVersion .. ", srv=" .. KBEngineLua.serverScriptVersion .. " )(脚本版本不匹配)";
	end
	
	GUI.contentColor = this.labelColor;
	GUI.Label(Rect.New((Screen.width / 2) - 100, 40, 400, 100), this.labelMsg);

	GUI.Label(Rect.New(0, 5, 400, 100), "client version: " .. KBEngineLua.clientVersion);
	GUI.Label(Rect.New(0, 20, 400, 100), "client script version: " .. KBEngineLua.clientScriptVersion);
	GUI.Label(Rect.New(0, 35, 400, 100), "server version: " .. KBEngineLua.serverVersion);
	GUI.Label(Rect.New(0, 50, 400, 100), "server script version: " .. KBEngineLua.serverScriptVersion);
end  

function UI.logError(s)
	this.labelColor = Color.red;
	this.labelMsg = s;
end

function UI.info(s)
	this.labelColor = Color.green;
	this.labelMsg = s;
end

function UI.login()
	this.info("connect to server...(连接到服务端...)");
	KBEngineLua.login(this.stringAccount, this.stringPasswd, "kbengine_unity3d_demo")
end

function UI.createAccount()
	this.info("connect to server...(连接到服务端...)");
	
	KBEngineLua.createAccount(this.stringAccount, this.stringPasswd, "kbengine_unity3d_demo");
end

function UI.onCreateAccountResult(retcode, datas)
	if(retcode ~= 0) then
		this.info("createAccount is error(注册账号错误)! err=" .. KBEngineLua.serverErrs[retcode].name);
		return;
	end
	
	if(KBEngineApp.validEmail(this.stringAccount)) then
		this.info("createAccount is successfully, Please activate your Email!(注册账号成功，请激活Email!)");
	else
		this.info("createAccount is successfully!(注册账号成功!)");
	end
end

function UI.onConnectionState(success)
	if(not success) then
		logError("connect(" .. KBEngineLua.getInitArgs().ip .. ":" .. KBEngineLua.getInitArgs().port .. ") is error! (连接错误)");
	else
		this.info("connect successfully, please wait...(连接成功，请等候...)");
	end
end

function UI.onLoginFailed(failedcode)
	if(failedcode == 20) then
		logError("login is failed(登陆失败), err=" .. KBEngineLua.serverlogError(failedcode) .. ", " .. System.Text.Encoding.ASCII.GetString(KBEngineLua.serverdatas()));
	else
		logError("login is failed(登陆失败), err=" .. KBEngineLua.serverlogError(failedcode));
	end
end

function UI.onVersionNotMatch(verInfo, serVerInfo)
	logError("");
end

function UI.onScriptVersionNotMatch(verInfo, serVerInfo)
	logError("");
end

function UI.onLoginBaseappFailed(failedcode)
	logError("loginBaseapp is failed(登陆网关失败), err=" .. KBEngineLua.serverlogError(failedcode));
end

function UI.onLoginBaseapp()
	this.info("connect to loginBaseapp, please wait...(连接到网关， 请稍后...)");
end

function UI.onReloginBaseappFailed(failedcode)
	logError("relogin is failed(重连网关失败), err=" .. KBEngineLua.serverlogError(failedcode));
	this.startRelogin = false;
end

function UI.onReloginBaseappSuccessfully()
	this.info("relogin is successfully!(重连成功!)");
	this.startRelogin = false;
end

function UI.onLoginSuccessfully(rndUUID, eid, accountEntity)
	this.info("login is successfully!(登陆成功!)");
	ui_state = 1;

	Application.LoadLevel("selavatars");
end

function UI.onKicked(failedcode)
	logError("kick, disconnect!, reason=" .. KBEngineLua.serverlogError(failedcode));
	Application.LoadLevel("login");
	ui_state = 0;
end

function UI.Loginapp_importClientMessages()
	this.info("Loginapp_importClientMessages ...");
end

function UI.Baseapp_importClientMessages()
	this.info("Baseapp_importClientMessages ...");
end

function UI.Baseapp_importClientEntityDef()
	this.info("importClientEntityDef ...");
end

function UI.onReqAvatarList(avatarList)
	this.ui_avatarList = avatarList;
end

function UI.onCreateAvatarResult(retcode, info, avatarList)
	if(retcode ~= 0) then
		logError("Error creating avatar, errcode=" .. retcode);
		return;
	end
	
	onReqAvatarList(avatarList);
end

function UI.onRemoveAvatar(dbid, avatarList)
	if(dbid == 0) then
		logError("Delete the avatar error!(删除角色错误!)");
		return;
	end
	
	onReqAvatarList(avatarList);
end

function UI.onDisconnected()
	logError("disconnect! will try to reconnect...(你已掉线，尝试重连中!)");
	this.startRelogin = true;
	Invoke("onReloginBaseappTimer", 1.0);
end

function UI.onReloginBaseappTimer() 
	if(ui_state == 0) then
		logError("disconnect! (你已掉线!)");
		return;
	end

	KBEngineLua.reloginBaseapp();
	
	if(this.startRelogin) then
		Invoke("onReloginBaseappTimer", 3.0);
	end
end
