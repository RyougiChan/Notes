using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RainbowColour : MonoBehaviour {

    Renderer rend;
    Material material;

	// Use this for initialization
	void Start () {
        rend = GetComponent<Renderer>();
        /// <see cref="https://docs.unity3d.com/ScriptReference/Material.html"/>
        material = rend.material;
        material.SetColor("_Colour", Color.magenta);
	}
}
