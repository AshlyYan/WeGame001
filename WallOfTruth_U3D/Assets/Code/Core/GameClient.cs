using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;

public class GameClient : MonoBehaviour
{
    static GameClient _instance = null;
    public static GameClient Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = GameObject.FindObjectOfType(typeof(GameClient)) as GameClient;
                if (_instance == null)
                {
                    GameObject go = new GameObject();
                    _instance = go.AddComponent<GameClient>();
                }
                _instance.gameObject.name = "GameClient";
                if (Application.isPlaying)
                    DontDestroyOnLoad(_instance.gameObject);
            }
            return _instance;
        }
    }


    void Awake()
    {
        if (Instance != this)
        {
            DestroyImmediate(gameObject);
            return;
        }
    }
    // Use this for initialization
    void Start()
    {
        if (!Application.isPlaying)
            return;
    }

    void OnApplicationPause(bool bPaused)
    {
        if (bPaused)
            return;
        UILabel[] labels = NGUITools.FindActive<UILabel>();
        foreach (UILabel lbl in labels)
        {
            if (lbl.bitmapFont == null)
                continue;
            UIFont font = lbl.bitmapFont;
            while (font.replacement != null)
                font = font.replacement;
            if (font.isDynamic)
            {
                lbl.MarkAsChanged();
            }
        }
    }

    protected static IEnumerator DelayCall(System.Action cb, float delay)
    {
        if (delay == 0)
            yield return null;
        else
            yield return new WaitForSeconds(delay);
        cb();
    }

    protected static IEnumerator DelayCall(System.Action<int> cb, int ret, float delay)
    {
        if (delay == 0)
            yield return null;
        else
            yield return new WaitForSeconds(delay);
        cb(ret);
    }

    public System.Action<int> NextTick(System.Action<int> func, int ret, float delay)
    {
        if (func != null)
            StartCoroutine(DelayCall(func, ret, delay));
        return func;
    }

    public System.Action NextTick(System.Action func)
    {
        return NextTick(func, 0);
    }
    public System.Action NextTick(System.Action func, float delay)
    {
        if (func != null)
            StartCoroutine(DelayCall(func, delay));
        return func;
    }
}
