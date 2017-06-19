using KBEngine;
using UnityEngine;
using System; 
using System.IO;  
using System.Collections; 
using System.Collections.Generic;
using System.Linq;

public class UI : MonoBehaviour 
{
	public static UI inst;

	void Awake() 
	 {
		inst = this;
		DontDestroyOnLoad(transform.gameObject);
	 }
	 
	// Use this for initialization
	void Start () 
	{

	}

	void OnDestroy()
	{
		
	}
	
	// Update is called once per frame
	void Update ()
	{
        
	}

    void OnGUI()  
    {  
		
	}  

}
