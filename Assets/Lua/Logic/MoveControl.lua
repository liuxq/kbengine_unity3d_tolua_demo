RotationAxes = 
{ 
    MouseXAndY = 0, MouseX = 1, MouseY = 2,
};

MoveControl = {
    axes = RotationAxes.MouseXAndY,
    sensitivityX = 15,
    sensitivityY = 15,

    minimumY = -60,
    maximumY = 60,

    rotationY = 0,

    moveSpeed = 0.05,
    transform = nil,
};

local this = MoveControl;

function MoveControl.StartUpdate()
    UpdateBeat:Add(MoveControl.Update, MoveControl);
end

function MoveControl.Update( )
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

    local directionVector = Vector3.New(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
    
    if (directionVector ~= Vector3.zero) then
        -- Get the length of the directon vector and then normalize it
        -- Dividing by the length is cheaper than normalizing when we already have the length anyway
        local directionLength = directionVector.magnitude;
        directionVector = directionVector / directionLength;
        
        -- Make sure the length is no bigger than 1
        directionLength = Mathf.Min(1, directionLength);
        
        -- Make the input vector more sensitive towards the extremes and less sensitive in the middle
        -- This makes it easier to control slow speeds when using analog sticks
        directionLength = directionLength * directionLength;
        
        -- Multiply the normalized direction vector by the modified length
        directionVector = directionVector * directionLength;
    end
    
    -- Apply the direction to the CharacterMotor
    this.transform.position = this.transform.position + this.transform.rotation * directionVector * this.moveSpeed;
end
