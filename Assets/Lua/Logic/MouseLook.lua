RotationAxes = 
{ 
    MouseXAndY = 0, MouseX = 1, MouseY = 2,
};

MouseLook = {
    axes = RotationAxes.MouseXAndY,
    sensitivityX = 15,
    sensitivityY = 15,

    minimumY = -60,
    maximumY = 60,

    rotationY = 0,
    transform = nil,
};

local this = MouseLook;

function MouseLook.StartUpdate()
    UpdateBeat:Add(MouseLook.Update, MouseLook);
end

function MouseLook.Update( )
    local Input = UnityEngine.Input;
    if (Input.GetMouseButton (1)) then
        if (this.axes == RotationAxes.MouseXAndY)  then
            local rotationX = this.transform.localEulerAngles.y + Input.GetAxis ("Mouse X") * this.sensitivityX;

            this.rotationY = this.rotationY + Input.GetAxis ("Mouse Y") * this.sensitivityY;
            this.rotationY = Mathf.Clamp (this.rotationY, this.minimumY, this.maximumY);

            this.transform.localEulerAngles = Vector3.New(-this.rotationY, rotationX, 0);
        elseif (this.axes == RotationAxes.MouseX)  then
            this.transform.Rotate (0, Input.GetAxis ("Mouse X") * this.sensitivityX, 0);
        else
            this.rotationY = this.rotationY + Input.GetAxis ("Mouse Y") * this.sensitivityY;
            this.rotationY = Mathf.Clamp (this.rotationY, this.minimumY, this.maximumY);

            this.transform.localEulerAngles = Vector3.New(-this.rotationY, this.transform.localEulerAngles.y, 0);
        end
    end
end
