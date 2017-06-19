
UI = {
	ui_state = 0,
	stringAccount = "",
	stringPasswd = "",
	labelMsg = "",
	labelColor = Color.green,
	ui_avatarList = null,
	
	stringAvatarName = "",
	startCreateAvatar = false,

	selAvatarDBID = 0,
	showReliveGUI = false,
	
	startRelogin = false,
};

function UI.Start() 
	installEvents();
	Application.LoadLevel("login");
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
	KBEngine.Event.deregisterOut(this);
end

--Update is called once per framefunction UI.Update ()
    if (Input.GetKeyUp(KeyCode.Space))
    {
		Debug.Log("KeyCode.Space");
		KBEngine.Event.fireIn("jump");
    end
end
function UI.onSelAvatarUI()
	if (startCreateAvatar == false && GUI.Button(new Rect(Screen.width / 2 - 100, Screen.height - 40, 200, 30), "RemoveAvatar(删除角色)"))    
    {
		if(selAvatarDBID == 0)
		{
			err("Please select a Avatar!(请选择角色!)");
		end
		else
		{
			info("Please wait...(请稍后...)");
			
			if(ui_avatarList != null && ui_avatarList.Count > 0)
			{
				Dictionary<string, object> avatarinfo = ui_avatarList[selAvatarDBID];
				KBEngine.Event.fireIn("reqRemoveAvatar", (string)avatarinfo["name"]);
			end
		end
    end

	if (startCreateAvatar == false && GUI.Button(new Rect(Screen.width / 2 - 100, Screen.height - 75, 200, 30), "CreateAvatar(创建角色)"))    
	{
		startCreateAvatar = !startCreateAvatar;
	end

    if (startCreateAvatar == false && GUI.Button(new Rect(Screen.width / 2 - 100, Screen.height - 110, 200, 30), "EnterGame(进入游戏)"))    
    {
    	if(selAvatarDBID == 0)
    	{
    		err("Please select a Avatar!(请选择角色!)");
    	end
    	else
    	{
    		info("Please wait...(请稍后...)");
    		
			KBEngine.Event.fireIn("selectAvatarGame", selAvatarDBID);
			Application.LoadLevel("world");
			ui_state = 2;
		end
    end
	
	if(startCreateAvatar)
	{
        if (GUI.Button(new Rect(Screen.width / 2 - 100, Screen.height - 40, 200, 30), "CreateAvatar-OK(创建完成)"))    
        {
        	if(stringAvatarName.Length > 1)
        	{
	        	startCreateAvatar = !startCreateAvatar;
				KBEngine.Event.fireIn("reqCreateAvatar", (Byte)1, stringAvatarName);
			end
			else
			{
				err("avatar name is null(角色名称为空)!");
			end
        end
        
        stringAvatarName = GUI.TextField(new Rect(Screen.width / 2 - 100, Screen.height - 75, 200, 30), stringAvatarName, 20);
	end
	
	if(ui_avatarList != null && ui_avatarList.Count > 0)
	{
		int idx = 0;
		foreach(UInt64 dbid in ui_avatarList.Keys)
		{
			Dictionary<string, object> info = ui_avatarList[dbid];
		//	Byte roleType = (Byte)info["roleType"];
			string name = (string)info["name"];
		//	UInt16 level = (UInt16)info["level"];
			UInt64 idbid = (UInt64)info["dbid"];

			idx++;
			
			Color color = GUI.contentColor;
			if(selAvatarDBID == idbid)
			{
				GUI.contentColor = Color.red;
			end
			
			if (GUI.Button(new Rect(Screen.width / 2 - 100, Screen.height / 2 + 120 - 35 * idx, 200, 30), name))    
			{
				Debug.Log("selAvatar:" + name);
				selAvatarDBID = idbid;
			end
			
			GUI.contentColor = color;
		end
	end
	else
	{
		if(KBEngineApp.app.entity_type == "Account")
		{
			KBEngine.Account account = (KBEngine.Account)KBEngineApp.app.player();
			if(account != null)
				ui_avatarList = new Dictionary<ulong, Dictionary<string, object>>(account.avatars);
		end
	end
end
function UI.onLoginUI()
	if(GUI.Button(new Rect(Screen.width / 2 - 100, Screen.height / 2 + 30, 200, 30), "Login(登陆)"))  
    {  
    	Debug.Log("stringAccount:" + stringAccount);
    	Debug.Log("stringPasswd:" + stringPasswd);
    	
		if(stringAccount.Length > 0 && stringPasswd.Length > 5)
		{
			login();
		end
		else
		{
			err("account or password is error, length < 6!(账号或者密码错误，长度必须大于5!)");
		end
    end

    if (GUI.Button(new Rect(Screen.width / 2 - 100, Screen.height / 2 + 70, 200, 30), "CreateAccount(注册账号)"))  
    {  
		Debug.Log("stringAccount:" + stringAccount);
		Debug.Log("stringPasswd:" + stringPasswd);

		if(stringAccount.Length > 0 && stringPasswd.Length > 5)
		{
			createAccount();
		end
		else
		{
			err("account or password is error, length < 6!(账号或者密码错误，长度必须大于5!)");
		end
    end
    
	stringAccount = GUI.TextField(new Rect (Screen.width / 2 - 100, Screen.height / 2 - 50, 200, 30), stringAccount, 20);
	stringPasswd = GUI.PasswordField(new Rect (Screen.width / 2 - 100, Screen.height / 2 - 10, 200, 30), stringPasswd, '*');
end
function UI.onWorldUI()
	if(showReliveGUI)
	{
		if(GUI.Button(new Rect(Screen.width / 2 - 100, Screen.height / 2, 200, 30), "Relive(复活)"))  
		{
			KBEngine.Event.fireIn("relive", (Byte)1);		        	
		end
	end
	
	UnityEngine.GameObject obj = UnityEngine.GameObject.Find("player(Clone)");
	if(obj != null)
	{
		GUI.Label(new Rect((Screen.width / 2) - 100, 20, 400, 100), "position=" + obj.transform.position.ToString()); 
	end
end

function UI.OnGUI()  

	if(ui_state == 1)
	{
		onSelAvatarUI();
		end
		else if(ui_state == 2)
		{
		onWorldUI();
		end
		else
		{
			onLoginUI();
		end
		
	if(KBEngineApp.app != null && KBEngineApp.app.serverVersion != "" 
		&& KBEngineApp.app.serverVersion != KBEngineApp.app.clientVersion)
	{
		labelColor = Color.red;
		labelMsg = "version not match(curr=" + KBEngineApp.app.clientVersion + ", srv=" + KBEngineApp.app.serverVersion + " )(版本不匹配)";
	end
	else if(KBEngineApp.app != null && KBEngineApp.app.serverScriptVersion != "" 
		&& KBEngineApp.app.serverScriptVersion != KBEngineApp.app.clientScriptVersion)
	{
		labelColor = Color.red;
		labelMsg = "scriptVersion not match(curr=" + KBEngineApp.app.clientScriptVersion + ", srv=" + KBEngineApp.app.serverScriptVersion + " )(脚本版本不匹配)";
	end
	
	GUI.contentColor = labelColor;
	GUI.Label(new Rect((Screen.width / 2) - 100, 40, 400, 100), labelMsg);

	GUI.Label(new Rect(0, 5, 400, 100), "client version: " + KBEngine.KBEngineApp.app.clientVersion);
	GUI.Label(new Rect(0, 20, 400, 100), "client script version: " + KBEngine.KBEngineApp.app.clientScriptVersion);
	GUI.Label(new Rect(0, 35, 400, 100), "server version: " + KBEngine.KBEngineApp.app.serverVersion);
	GUI.Label(new Rect(0, 50, 400, 100), "server script version: " + KBEngine.KBEngineApp.app.serverScriptVersion);
end  

function UI.err(string s)
	labelColor = Color.red;
	labelMsg = s;
end

function UI.info(string s)
	labelColor = Color.green;
	labelMsg = s;
end

function UI.login()
	info("connect to server...(连接到服务端...)");
	KBEngine.Event.fireIn("login", stringAccount, stringPasswd, System.Text.Encoding.UTF8.GetBytes("kbengine_unity3d_demo"));
end

function UI.createAccount()
	info("connect to server...(连接到服务端...)");
	
	KBEngine.Event.fireIn("createAccount", stringAccount, stringPasswd, System.Text.Encoding.UTF8.GetBytes("kbengine_unity3d_demo"));
end

function UI.onCreateAccountResult(UInt16 retcode, byte[] datas)
	if(retcode != 0)
	{
		err("createAccount is error(注册账号错误)! err=" + KBEngineApp.app.serverErr(retcode));
		return;
	end
	
	if(KBEngineApp.validEmail(stringAccount))
	{
		info("createAccount is successfully, Please activate your Email!(注册账号成功，请激活Email!)");
	end
	else
	{
		info("createAccount is successfully!(注册账号成功!)");
	end
end

function UI.onConnectionState(bool success)
	if(!success)
		err("connect(" + KBEngineApp.app.getInitArgs().ip + ":" + KBEngineApp.app.getInitArgs().port + ") is error! (连接错误)");
	else
		info("connect successfully, please wait...(连接成功，请等候...)");
end

function UI.onLoginFailed(UInt16 failedcode)
	if(failedcode == 20)
	{
		err("login is failed(登陆失败), err=" + KBEngineApp.app.serverErr(failedcode) + ", " + System.Text.Encoding.ASCII.GetString(KBEngineApp.app.serverdatas()));
	end
	else
	{
		err("login is failed(登陆失败), err=" + KBEngineApp.app.serverErr(failedcode));
	end
end

function UI.onVersionNotMatch(string verInfo, string serVerInfo)
	err("");
end

function UI.onScriptVersionNotMatch(string verInfo, string serVerInfo)
	err("");
end

function UI.onLoginBaseappFailed(UInt16 failedcode)
	err("loginBaseapp is failed(登陆网关失败), err=" + KBEngineApp.app.serverErr(failedcode));
end

function UI.onLoginBaseapp()
	info("connect to loginBaseapp, please wait...(连接到网关， 请稍后...)");
end

function UI.onReloginBaseappFailed(UInt16 failedcode)
	err("relogin is failed(重连网关失败), err=" + KBEngineApp.app.serverErr(failedcode));
	startRelogin = false;
end

function UI.onReloginBaseappSuccessfully()
	info("relogin is successfully!(重连成功!)");
	startRelogin = false;
end

function UI.onLoginSuccessfully(UInt64 rndUUID, Int32 eid, Account accountEntity)
	info("login is successfully!(登陆成功!)");
	ui_state = 1;

	Application.LoadLevel("selavatars");
end

function UI.onKicked(UInt16 failedcode)
	err("kick, disconnect!, reason=" + KBEngineApp.app.serverErr(failedcode));
	Application.LoadLevel("login");
	ui_state = 0;
end

function UI.Loginapp_importClientMessages()
	info("Loginapp_importClientMessages ...");
end

function UI.Baseapp_importClientMessages()
	info("Baseapp_importClientMessages ...");
end

function UI.Baseapp_importClientEntityDef()
	info("importClientEntityDef ...");
end

function UI.onReqAvatarList(Dictionary<UInt64, Dictionary<string, object>> avatarList)
	ui_avatarList = avatarList;
end

function UI.onCreateAvatarResult(Byte retcode, object info, Dictionary<UInt64, Dictionary<string, object>> avatarList)
	if(retcode != 0)
	{
		err("Error creating avatar, errcode=" + retcode);
		return;
	end
	
	onReqAvatarList(avatarList);
end

function UI.onRemoveAvatar(UInt64 dbid, Dictionary<UInt64, Dictionary<string, object>> avatarList)
	if(dbid == 0)
	{
		err("Delete the avatar error!(删除角色错误!)");
		return;
	end
	
	onReqAvatarList(avatarList);
end

function UI.onDisconnected()
	err("disconnect! will try to reconnect...(你已掉线，尝试重连中!)");
	startRelogin = true;
	Invoke("onReloginBaseappTimer", 1.0f);
end

function UI.onReloginBaseappTimer() 
	if(ui_state == 0)
	{
		err("disconnect! (你已掉线!)");
		return;
	end

	KBEngineApp.app.reloginBaseapp();
	
	if(startRelogin)
		Invoke("onReloginBaseappTimer", 3.0f);
end
end
