using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public AnimationCurve curveTo2D;
    public AnimationCurve curveTo3D;

    BackupCameraProjectionChange viewSwitcher;
    Camera cameraSelf;
    Charactor charactor;

    Transform tsfPosPoint;
    Transform tsf2DPos;
    Transform tsf3DPos;

    float f2DPos_Y = 0;
    float f3DPos_Y = 0;

    bool bIsChanging = false;
    bool bIsTweenRotation = false;

    public bool CurrentIs2D { get { return cameraSelf.orthographic; } }

    void Awake()
    {
        viewSwitcher = GetComponent<BackupCameraProjectionChange>();
        cameraSelf = GetComponent<Camera>();
    }

    public void Init(Charactor chara, Transform tsfPointsRoot, Transform tsf2D, Transform tsf3D)
    {
        charactor = chara;
        tsfPosPoint = tsfPointsRoot;
        tsf2DPos = tsf2D;
        tsf3DPos = tsf3D;

        f2DPos_Y = tsf2D.position.y;
        f3DPos_Y = tsf3D.position.y;
    }

    public void Switch(System.Action callback) { Switch(!CurrentIs2D, callback); }
    public void Switch(bool to2D, System.Action callback)
    {
        if (bIsChanging || !viewSwitcher.CanChange || to2D == CurrentIs2D) return;
        bIsChanging = true;
        viewSwitcher.ChangeProjection = true;

        Vector3 vec = to2D ? tsf2DPos.position : tsf3DPos.position;
        vec.y = to2D ? f2DPos_Y : f3DPos_Y;
        UITweener tween = TweenPosition.Begin(gameObject, viewSwitcher.ProjectionChangeTime - 0.25f, vec, true);
        tween.animationCurve = to2D ? curveTo2D : curveTo3D;
        tween.SetOnFinished(() =>
         {
             bIsTweenRotation = true;
             Vector3 vec2 = to2D ? tsf2DPos.position : tsf3DPos.position;
             vec.y = to2D ? f2DPos_Y : f3DPos_Y;
             TweenPosition.Begin(gameObject, 0.3f, vec, true);
             TweenRotation.Begin(gameObject, 0.3f, to2D ? tsf2DPos.rotation : tsf3DPos.rotation, true).SetOnFinished(() =>
             {
                 bIsTweenRotation = bIsChanging = false;
                 if (callback != null)
                     callback();
             });
         });
    }

    private void LateUpdate()
    {
        if (bIsChanging)
        {
            if (!bIsTweenRotation)
                cameraSelf.transform.LookAt(charactor.transform);
            return;
        }
        Vector3 vec = tsfPosPoint.eulerAngles;
        vec.y = 0;
        tsfPosPoint.eulerAngles = vec;

        vec = CurrentIs2D ? tsf2DPos.position : tsf3DPos.position;
        vec.y = CurrentIs2D ? f2DPos_Y : f3DPos_Y;
        transform.position = vec;
    }
}
