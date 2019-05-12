using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Manager : MonoBehaviour
{
    private float trackState = 0;
    private float newState = 0;
    private Renderer rend;

    void Awake()
    {
        rend = GetComponent<Renderer>();
    }

    private void OnGUI()
    {
        int xCenter = (Screen.width / 2);
        int yCenter = (Screen.height / 2);
        int width = 100;
        int height = 60;

        GUIStyle fontSize = new GUIStyle(GUI.skin.GetStyle("button"));
        fontSize.fontSize = 32;

        Scene scene = SceneManager.GetActiveScene();

        if (GUI.Button(new Rect(10, 10, width, height), "Map 1", fontSize))
        {
            if (newState == 2f)
            {
                trackState = 2f;
                newState = 3f;
            }
            if(newState != 3f) newState = 0.0f;
        }
        if (GUI.Button(new Rect(10 * 2 + width, 10, width, height), "Map 2", fontSize))
        {
            newState = 1.0f;
        }
        if (GUI.Button(new Rect(10 * 3 + width * 2, 10, width, height), "Map 3", fontSize))
        {
            if (newState == 0f)
            {
                trackState = 3f;
                newState = 2.0f;
            }
            if (newState != 0f) newState = 2.0f;
            
        }
        //if (GUI.Button(new Rect(10 * 4 + width * 3, 10, width, height), "Quit", fontSize))
        {
          //  Application.Quit();
        }
    }

    void Update()
    {
        trackState = Mathf.Lerp(trackState, newState, 0.02f);
        rend.material.SetFloat("_CurrMap", trackState);
    }
}
