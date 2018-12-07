using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Charactor : MonoBehaviour
{
    public enum Status
    {
        OnGround,
        Jump
    }

    public SequenceFrame[] extActions;
    public float fMoveSpeed = 0.2f;
    public AnimationCurve curveJump;
    public float fJumpStrength = 0.3f;
    public float fGravity = 0.2f;

    Dictionary<string, SequenceFrame> dicActions = new Dictionary<string, SequenceFrame>();
    SequenceFrame _currentAction;
    CharacterController controller;
    CameraController cameraController;
    Transform tsfPosPoint;
    new Rigidbody rigidbody;
    Status status = Status.OnGround;

    float fActiveGravity = 0;

    public SequenceFrame CurrentAction
    {
        get { return _currentAction; }
        protected set
        {
            if (_currentAction == value) return;
            if (_currentAction)
                _currentAction.Stop();
            _currentAction = value;
            CurrentAction.Play();
        }
    }

    void Start()
    {
        SequenceFrame[] actions = GetComponentsInChildren<SequenceFrame>(true);
        for (int i = 0, length = actions.Length; i < length; ++i)
            dicActions[actions[i].name] = actions[i];
        for (int i = 0, length = extActions.Length; i < length; ++i)
            dicActions[actions[i].name] = extActions[i];

        tsfPosPoint = transform.Find("PosPoint");

        rigidbody = GetComponent<Rigidbody>();
        controller = GetComponent<CharacterController>();
        cameraController = FindObjectOfType<CameraController>().GetComponent<CameraController>();
        cameraController.Init(this, tsfPosPoint, tsfPosPoint.Find("2DCameraPos"), tsfPosPoint.Find("3DCameraPos"));

        fActiveGravity = -fGravity;
    }

    void Update()
    {
        ProcessMove();
        if (Input.GetKeyDown(KeyCode.F))
            cameraController.Switch(null);
    }

    void ProcessMove()
    {
        if (status != Status.Jump && !controller.isGrounded)
            StartCoroutine("Drop");
        if (status != Status.Jump && Input.GetKeyDown(KeyCode.Space))
            StartCoroutine("Jump");
        float hori = Input.GetAxis("Horizontal") * fMoveSpeed * Time.deltaTime;
        float vert = Input.GetAxis("Vertical") * fMoveSpeed * Time.deltaTime;
        Vector3 move = new Vector3(hori * fMoveSpeed, fActiveGravity, 0);
        controller.Move(move);
        Vector3 euler = transform.eulerAngles;
        euler.y = hori < 0 ? 180 : 0;
        transform.eulerAngles = euler;
    }

    IEnumerator Jump()
    {
        status = Status.Jump;
        fActiveGravity = 0;
        for (int i = 0; i < 4; ++i)
        {
            if (status == Status.OnGround)
                yield break;
            fActiveGravity = curveJump.Evaluate(i / 3f) * fJumpStrength;
            yield return new WaitForSeconds(0.1f);
        }
        yield return 0;
        StartCoroutine("Drop");
    }

    IEnumerator Drop()
    {
        while (!controller.isGrounded)
        {
            if (fActiveGravity > Physics.gravity.y)
                fActiveGravity -= fGravity;
            yield return new WaitForSeconds(0.1f);
        }
        StopCoroutine("Jump");
        status = Status.OnGround;
        fActiveGravity = -fGravity;
    }
}
