using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Racer : MonoBehaviour
{
    public float MaxSpeed = 0.1f;
    public float MaxAccel = 0.001f;
    public float SteerHandle = 0.1f;
    public float CameraDistance = 10;

    private Vector3 steer = Vector3.zero;
    private float accel = 0f;
    private float hor = 0;
    private float ver = 1;

    private Camera Cam;
    // Start is called before the first frame update
    void Start()
    {
        Cam = FindObjectOfType<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 p = this.transform.position;
        Cam.transform.position = p - Vector3.forward * CameraDistance + Vector3.up * CameraDistance;

        if (Input.GetAxisRaw("Horizontal") != 0 || Input.GetAxisRaw("Vertical") != 0 )
        {
            hor = Input.GetAxis("Horizontal") * 100;
            ver = Input.GetAxis("Vertical") * 100;
            if (accel < MaxSpeed) accel += MaxAccel;
            else accel = MaxSpeed;
        }
        else
        {
            if (accel > 0) accel -= MaxAccel * 3;
            else accel = 0;
        }
        steer = Vector3.Lerp(steer, new Vector3(p.x + hor,
                                           p.y,
                                           p.z + ver), SteerHandle);

        transform.LookAt(steer);
        transform.Rotate(0, 90, 0);
        transform.position += -transform.right * accel;
    }
}
