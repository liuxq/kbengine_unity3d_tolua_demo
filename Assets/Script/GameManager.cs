using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using System.Reflection;
using System.IO;


public class GameManager : MonoBehaviour {
    protected static bool initialize = false;

    LuaManager mLuaManager = null;
    /// <summary>
    /// 初始化游戏管理器
    /// </summary>
    void Awake() {
        Init();
    }

    /// <summary>
    /// 初始化
    /// </summary>
    void Init() {
        DontDestroyOnLoad(gameObject);  //防止销毁自己
        mLuaManager = gameObject.GetComponent<LuaManager>();
        OnInitialize();
    }

    void OnInitialize() {
        mLuaManager.InitStart();
        mLuaManager.DoFile("Logic/Game");         //加载游戏
        mLuaManager.CallFunction("Game.OnInitOK");     //初始化完成

        KBEngine.Event.fireIn("onResourceInitFinish");
        initialize = true;
    }

    /// <summary>
    /// 析构函数
    /// </summary>
    void OnDestroy() {
        if (mLuaManager != null)
        {
            mLuaManager.CallFunction("KBEngineLua.Destroy");
            mLuaManager.Close();
        }
        Debug.Log("~GameManager was destroyed");
    }
}
