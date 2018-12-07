using UnityEngine;
using System.Collections.Generic;

namespace RO
{
    [RequireComponent(typeof(UITexture))]
    public class RenderQByUI : MonoBehaviour
    {
        public bool excute = false;
        public int RenderQ;
        UITexture pic;
        GameObject child;
        Renderer catchRender;

        [ContextMenu("TestExcute")]
        public void TestExcute()
        {
            foreach (Transform t in transform)
            {
                AddChild(t.gameObject);
            }
        }

        public void AddChild(GameObject c)
        {
            child = c;
            c.transform.SetParent(transform, false);
        }

        void Awake()
        {
            pic = GetComponent<UITexture>();
            if (pic.mainTexture == null)
            {
                Texture occupy = new Texture();
                pic.mainTexture = occupy;
            }
            foreach (Transform t in transform)
            {
                if (t != null)
                {
                    AddChild(t.gameObject);
                }
            }
        }

        void Update()
        {
            if (pic != null && pic.drawCall != null)
            {
                if (catchRender == null || catchRender.material.renderQueue != pic.drawCall.renderQueue)
                    changeRenderQ();
                if (!excute)
                {
                    changeRenderQ();
                    excute = true;
                }
            }
        }

        void changeRenderQ()
        {
            int rq = pic.drawCall.renderQueue;
            RenderQ = rq;
            if (child != null)
            {
                child.layer = LayerMask.NameToLayer("UI");
                child.transform.SetChildLayer(LayerMask.NameToLayer("UI"));
                Component[] cs = child.GetComponentsInChildren<Renderer>(true);
                for (int k = 0; k < cs.Length; k++)
                {
                    Renderer r = cs[k] as Renderer;
                    r.material.renderQueue = rq;
                    catchRender = r;
                }
            }
        }
    }
} // namespace RO
