#CONSTANT GRAV_CONSTANT 3 `set the gravity constant, 3 feels good

`Initialize screen
SetDisplayAspect( 1.6 )
SetVirtualResolution( 420, 260 )
SetViewZoomMode( 1 )
SetDefaultMagFilter( 0 )
SetVSync(1)

`figure out the center of the screen
Type screen
    center_x
    center_y
EndType

Global screen As screen

screen.center_x = GetVirtualWidth() / 2
screen.center_y = GetVirtualHeight() / 2


`Initialize Physics
`SetPhysicsDebugOn()
SetPhysicsGravity( 0,0 )
SetPhysicsWallBottom( 0 )
SetPhysicsWallLeft( 0 )
SetPhysicsWallRight( 0 )
SetPhysicsWallTop( 0 )
SetPhysicsMaxPolygonPoints( 12 )

LoadSound(1, "music/Around the Fireplace.wav")
LoadSound(2, "music/Home at last.wav")


`title screen, when everything's deleted, you can goto here
ReturnToTitle:
StopSound(2) `stop ingame music, play menu music
PlaySound(1,100,1)

`load the title screen and fix it to the display
titleScreen = LoadImage("title.png")
titleScreenSprite = CreateSprite(titleScreen)
FixSpriteToScreen( titleScreenSprite, 1 )

`initialize the map var
map = 0

`check for input and render the screen
Repeat
    If GetPointerPressed()
        `if the pointer is on the left box
        If GetPointerX() => 49 And GetPointerX() =< 123 And GetPointerY() => 160 And GetPointerY() =< 215
            map=LoadImage("maps/regularmoon.png")
        EndIf
        `middle
        If GetPointerX() => 176 And GetPointerX() =< 250 And GetPointerY() => 160 And GetPointerY() =< 215
            map=LoadImage("maps/catmoon.png")
        EndIf
        `right
        If GetPointerX() => 304 And GetPointerX() =< 378 And GetPointerY() => 160 And GetPointerY() =< 215
            `bring up a file chooser
            ShowChooseImageScreen()
            Repeat
                `render nothing until the user comes back to the main window
                Sync()
            Until IsChoosingImage()= 0
            `load whatever the user chose
            map=GetChosenImage()
        EndIf
    Endif
    Sync()
Until map > 0

`done with title screen, delete it
DeleteSprite(titleScreenSprite)
DeleteImage(titleScreen)
StopSound(1) `stop menu music, play ingame music
PlaySound(2, 100, 1)


`size of the map grid
Global grid_size_x As Integer
Global grid_size_y As Integer

LoadLevel(map, 0)

`a variable holding number of ships and characters on screen
Global number_of_ships As Integer
Global number_of_characters As Integer

`all of the ship information
Type ship
    old_velocity_X As Float
    old_velocity_Y As Float
    velocity_X As Float
    velocity_Y As Float
    old_gforce_X As Float
    old_gforce_Y As Float
    gforce_X As Float
    gforce_Y As Float
    old_gforce As Float
    gforce As Float
    gforce_change As Float

    passenger_ID As Integer
    passenger_joint_ID As Integer

    sprite_ID As Integer
    image_ID AS Integer
    thruster_image_ID As Integer

    passenger_offset_x As Float
    passenger_offset_y As Float


    thruster_1_sprite_ID As Integer
    thruster_2_sprite_ID As Integer
    thruster_3_sprite_ID As Integer
    thruster_4_sprite_ID As Integer

    thruster_1_sound_ID As Integer
    thruster_2_sound_ID As Integer
    thruster_3_sound_ID As Integer
    thruster_4_sound_ID As Integer

    thruster_1_joint_ID As Integer
    thruster_2_joint_ID As Integer
    thruster_3_joint_ID As Integer
    thruster_4_joint_ID As Integer

    thruster_1_x As Float
    thruster_1_y As Float
    thruster_2_x As Float
    thruster_2_y As Float
    thruster_3_x As Float
    thruster_3_y As Float
    thruster_4_x As Float
    thruster_4_y As Float

    thruster_1_angle As Float
    thruster_2_angle As Float
    thruster_3_angle As Float
    thruster_4_angle As Float

    thruster_1_real_x As Float
    thruster_1_real_y As Float
    thruster_2_real_x As Float
    thruster_2_real_y As Float
    thruster_3_real_x As Float
    thruster_3_real_y As Float
    thruster_4_real_x As Float
    thruster_4_real_y As Float
EndType

`all of the character information
Type character
    image_ID As Integer
    sprite_ID As Integer

    ship_ID As Integer
    ship_joint_ID As Integer

    controlled_by As Integer
        `0 = static
        `1-32 = player 32
        `33 = cpu

    input_up As Integer
    input_down As Integer
    input_left As Integer
    input_right As Integer
    input_left_up As Integer
    input_right_up As Integer
EndType

`loads ship from text file data, for easy modding
shipID = LoadShip("ship.txt")
`shipID2 = LoadShip("ship.txt") `add a second ship for fun!
char = LoadCharacter("characters/mali.png") `someone needs to pilot the ship

CharacterBoardShip(char, shipID) `attach mali to the ship



`Initialize GUI Guages
img_grav_locator = LoadImage("gui/gravity-locator.png")
img_grav_needle =LoadImage("gui/gravity-locator-needle.png")

spr_grav_locator = CreateSprite(img_grav_locator)
spr_grav_needle = CreateSprite(img_grav_needle)


FixSpriteToScreen( spr_grav_locator, 1 )
FixSpriteToScreen( spr_grav_needle, 1 )

SetSpriteScale(spr_grav_locator, 0.5,0.5)
SetSpriteScale(spr_grav_needle, 0.5,0.5)

SetSpriteOffset(spr_grav_locator, GetSpriteWidth(spr_grav_locator)/2, GetSpriteHeight(spr_grav_locator)/2)
SetSpriteOffset(spr_grav_needle, GetSpriteWidth(spr_grav_needle)/2, GetSpriteHeight(spr_grav_needle)/2)




`Initialize Solar System as a 3d sphere
LoadImage(8, "images/stars2.png")
CreateObjectSphere( 1, -15, 18, 16 )
SetObjectImage( 1, 8, 0 )
`SetObjectVisible( 1, 0 )


LoadImage(9, "images/sun.png")
CreateObjectPlane(2, 0.2,0.2)
SetObjectImage( 2, 9, 0 )
SetObjectTransparency( 2, 1 )
SetObjectPosition(2,0,-1,7)
SetObjectRotation(2, GetCameraAngleX(1),0,GetCameraAngleZ(1))

`Initialize Lense flares
Type lense_flare
    distance_from_center As Float
    image_ID As Integer
    image_name As String
    scale As Float
    sprite_ID As Integer
EndType

#CONSTANT flare_size 10

object_screen_x As Float
object_screen_y As Float

percent_x As Float
percent_y As Float

direction_vector_x As Float
direction_vector_y As Float
distance_of_vector As Float

brightness As Float

Dim flare[4] As lense_flare

flare[1].distance_from_center = 100
flare[1].image_name = "images/flare1.png"
flare[1].scale = 2
flare[1].image_ID = LoadImage( flare[1].image_name )
flare[1].sprite_ID =  CreateSprite( flare[1].image_ID )
SetSpriteSize(flare[1].sprite_ID, flare_size,flare_size)
SetSpriteVisible ( flare[1].sprite_ID, 0 )
FixSpriteToScreen( flare[1].sprite_ID, 1 )
SetSpriteScale(flare[1].sprite_ID, flare[1].scale,flare[1].scale)

flare[2].distance_from_center = 50
flare[2].image_name = "images/flare2.png"
flare[2].scale = 3
flare[2].image_ID = LoadImage( flare[2].image_name )
flare[2].sprite_ID =  CreateSprite( flare[2].image_ID )
SetSpriteSize(flare[2].sprite_ID, flare_size,flare_size)
SetSpriteVisible ( flare[2].sprite_ID, 0 )
FixSpriteToScreen( flare[2].sprite_ID, 1 )
SetSpriteScale(flare[2].sprite_ID, flare[2].scale,flare[2].scale)

flare[3].distance_from_center = 120
flare[3].image_name = "images/flare3.png"
flare[3].scale = 5
flare[3].image_ID = LoadImage( flare[3].image_name )
flare[3].sprite_ID =  CreateSprite( flare[3].image_ID )
SetSpriteSize(flare[3].sprite_ID, flare_size,flare_size)
SetSpriteVisible ( flare[3].sprite_ID, 0 )
FixSpriteToScreen( flare[3].sprite_ID, 1 )
SetSpriteScale(flare[3].sprite_ID, flare[3].scale,flare[3].scale)

flare[4].distance_from_center = 75
flare[4].image_name = "images/flare4.png"
flare[4].scale = 1
flare[4].image_ID = LoadImage( flare[1].image_name )
flare[4].sprite_ID =  CreateSprite( flare[4].image_ID )
SetSpriteSize(flare[4].sprite_ID, flare_size,flare_size)
SetSpriteVisible ( flare[4].sprite_ID, 0 )
FixSpriteToScreen( flare[4].sprite_ID, 1 )
SetSpriteScale(flare[4].sprite_ID, flare[4].scale,flare[4].scale)

`this is the white that brightens the screen when near the sun
CreateSprite( 14, 0)
SetSpriteSize(14, GetVirtualWidth(),GetVirtualHeight())
SetSpriteVisible ( 14, 0 )
FixSpriteToScreen( 14, 1 )

`set the camera in 3d space, since the universe is a sphere
SetCameraPosition( 1, 0,0,0 )

`tmp variables
GravityX As Float
GravityY As Float
gravityPointPositionX As Float
gravityPointPositionY As Float
ShipMass As Float
GravForce As Float

Do
    `loop through every ship, usually it's just 1 in this demo, unless you create more ships up above
    For on_ship = 1 To number_of_ships

        `record the old ship information and update the ships variables with the new physics info happening
        ship[on_ship].old_velocity_X = ship[on_ship].velocity_X
        ship[on_ship].velocity_X = GetSpritePhysicsVelocityX( ship[on_ship].sprite_ID )
        ship[on_ship].old_velocity_Y = ship[on_ship].velocity_Y
        ship[on_ship].velocity_Y = GetSpritePhysicsVelocityY( ship[on_ship].sprite_ID )

        `calculate velocity and gforces, for use when making particles
        ship[on_ship].gforce_X = ship[on_ship].velocity_X - ship[on_ship].old_velocity_X
        ship[on_ship].gforce_Y = ship[on_ship].velocity_Y - ship[on_ship].old_velocity_Y
        ship[on_ship].old_gforce = ship[on_ship].gforce
        ship[on_ship].gforce = Sqrt((ship[on_ship].gforce_Y*ship[on_ship].gforce_Y)+(ship[on_ship].gforce_X*ship[on_ship].gforce_X))
        ship[on_ship].gforce_change = ship[on_ship].gforce - ship[on_ship].old_gforce

        `initialize the gravity
        GravityX = 0
        GravityY = 0

        `the magic, loop through every peice of the level, split up in a grid, usually 32 pixel chunks
        `we then take and calculate the gravity that each part of the level is inflicting on the ship. This lets us have intricate levels, instead of just spheres.
        `turn on physics debugging to see how it's split up
        For gravityPointY = 1 To grid_size_y
            For gravityPointX = 1 To grid_size_x
                If GetSpriteExists(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x)
                    gravityPointPositionX = GetSpriteXByOffset(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x) + (gravitywellOffset[gravityPointX,gravityPointY,1])
                    gravityPointPositionY = GetSpriteYByOffset(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x) + (gravitywellOffset[gravityPointX,gravityPointY,2])
                    `ShipDistance As Float
                    `ShipDistance = calculateDistance(gravityPointPositionX, gravityPointPositionY, GetSpriteXByOffset(ship[on_ship].sprite_ID), GetSpriteYByOffset(ship[on_ship].sprite_ID))
`                    GravForce = ShipDistance*(gravitywells[gravityPointX,gravityPointY] / 0.05 )

                    If ship[on_ship].passenger_ID > 0
                        `make sure if someone's in the ship we include their mass in the calculations!
                        ShipMass = GetSpritePhysicsMass( ship[on_ship].sprite_ID ) + GetSpritePhysicsMass( char[ship[on_ship].passenger_ID].sprite_ID )
                    Else
                        `an empty ship
                        ShipMass = GetSpritePhysicsMass( ship[on_ship].sprite_ID )
                    EndIf
                    `calculate the gravity based on the information gathered
                    GravForce = ((GRAV_CONSTANT*ShipMass*gravitywells[gravityPointX,gravityPointY])/(calculateDistance(GetSpriteXByOffset(ship[on_ship].sprite_ID), GetSpriteYByOffset(ship[on_ship].sprite_ID),gravityPointPositionX,gravityPointPositionY )^2))
                    GravForce = GravForce*(gravitywells[gravityPointX,gravityPointY]/ShipMass)

                    `add the gravity forces of every tile to come up with a total
                    GravityX = GravityX + COS(ATANFULL(GetSpriteXByOffset(ship[on_ship].sprite_ID)-gravityPointPositionX,GetSpriteYByOffset(ship[on_ship].sprite_ID)-gravityPointPositionY)+90) * (GravForce * GetFrameTime() )
                    GravityY = GravityY + SIN(ATANFULL(GetSpriteXByOffset(ship[on_ship].sprite_ID)-gravityPointPositionX,GetSpriteYByOffset(ship[on_ship].sprite_ID)-gravityPointPositionY)+90) * (GravForce * GetFrameTime() )


                EndIf
            Next gravityPointX
        Next gravityPointY

        `now we point the dashboard needle in the direction of the gravity
        SetSpriteAngle(spr_grav_needle, ATANFULL(GravityX,GravityY))

        `and we apply the total gravity forces to the spaceship
        SetSpritePhysicsForce( ship[on_ship].sprite_ID, GetSpriteXByOffset(ship[on_ship].sprite_ID), GetSpriteYByOffset(ship[on_ship].sprite_ID), GravityX, GravityY)

        `now we can reset gravity, and in a moment we will do the exact same gravity calculations on pilots that are not in a spaceship
        `unless you add more pilots in the code, you don't see this in the demo
        GravityX = 0
        GravityY = 0
        `loop characters through gravity of level and process input
        For on_char = 1 To number_of_characters
            `if the character is controlled by a keyboard, take the inputs
            If char[on_char].controlled_by = keyboard_player
                If GetRawKeyState(87) Or GetRawKeyState(56) `w or 8
                    char[on_char].input_up = 1
                Else
                    char[on_char].input_up = 0
                EndIf
                If GetRawKeyState(65) Or GetRawKeyState(52) `a or 4
                    char[on_char].input_left = 1
                Else
                    char[on_char].input_left = 0
                EndIf
                If  GetRawKeyState(83) Or GetRawKeyState(53) `s or 5
                    char[on_char].input_down = 1
                Else
                    char[on_char].input_down = 0
                EndIf
                If GetRawKeyState(68) Or GetRawKeyState(54) `d or 6
                    char[on_char].input_right = 1
                Else
                    char[on_char].input_right = 0
                EndIf
                If GetRawKeyState(81) Or GetRawKeyState(55) `q or 7
                    char[on_char].input_left_up = 1
                Else
                    char[on_char].input_left_up = 0
                EndIf
                If  GetRawKeyState(69) Or GetRawKeyState(57) `e or 9
                    char[on_char].input_right_up = 1
                Else
                    char[on_char].input_right_up = 0
                EndIf
            EndIf

            `if the character is in a spaceship
            If char[on_char].ship_ID > 0
                `apply the inputs from the pilot (usually from the keyboard unless you add AI) onto the spaceship
                `run or stop thruster sound effects as well
                If char[on_char].input_left Or char[on_char].input_down `a s
                    SetSpritePhysicsForce( ship[char[on_char].ship_ID].sprite_ID, GetSpriteXByOffset(ship[char[on_char].ship_ID].thruster_1_sprite_ID), GetSpriteYByOffset(ship[char[on_char].ship_ID].thruster_1_sprite_ID), Cos(GetSpriteAngle( ship[char[on_char].ship_ID].thruster_1_sprite_ID )-90)* 1000, Sin(GetSpriteAngle( ship[char[on_char].ship_ID].thruster_1_sprite_ID )-90) * 1000 )
                    SetSpriteVisible ( ship[char[on_char].ship_ID].thruster_1_sprite_ID, 1 )
                    If GetSoundInstances(ship[char[on_char].ship_ID].thruster_1_sound_ID) = 0 Then PlaySound( ship[char[on_char].ship_ID].thruster_1_sound_ID, 25, 1 )
                Else
                    SetSpriteVisible ( ship[char[on_char].ship_ID].thruster_1_sprite_ID, 0 )
                    StopSound( ship[char[on_char].ship_ID].thruster_1_sound_ID )
                EndIf
                If char[on_char].input_right Or char[on_char].input_down `d s
                    SetSpritePhysicsForce( ship[char[on_char].ship_ID].sprite_ID, GetSpriteXByOffset(ship[char[on_char].ship_ID].thruster_2_sprite_ID), GetSpriteYByOffset(ship[char[on_char].ship_ID].thruster_2_sprite_ID), Cos(GetSpriteAngle( ship[char[on_char].ship_ID].thruster_2_sprite_ID )-90 )* 1000, Sin(GetSpriteAngle( ship[char[on_char].ship_ID].thruster_2_sprite_ID )-90) * 1000 )
                    SetSpriteVisible ( ship[char[on_char].ship_ID].thruster_2_sprite_ID, 1 )
                    If GetSoundInstances(ship[char[on_char].ship_ID].thruster_2_sound_ID) = 0 Then PlaySound( ship[char[on_char].ship_ID].thruster_2_sound_ID, 25, 1 )
                Else
                    SetSpriteVisible ( ship[char[on_char].ship_ID].thruster_2_sprite_ID, 0 )
                    StopSound( ship[char[on_char].ship_ID].thruster_2_sound_ID )
                Endif
                If char[on_char].input_right_up Or char[on_char].input_up `e w
                    SetSpritePhysicsForce( ship[char[on_char].ship_ID].sprite_ID, GetSpriteXByOffset(ship[char[on_char].ship_ID].thruster_3_sprite_ID), GetSpriteYByOffset(ship[char[on_char].ship_ID].thruster_3_sprite_ID), Cos(GetSpriteAngle( ship[char[on_char].ship_ID].thruster_3_sprite_ID )-90)* 1000, Sin(GetSpriteAngle( ship[char[on_char].ship_ID].thruster_3_sprite_ID )-90) * 1000 )
                    SetSpriteVisible ( ship[char[on_char].ship_ID].thruster_3_sprite_ID, 1 )
                    If GetSoundInstances(ship[char[on_char].ship_ID].thruster_3_sound_ID) = 0 Then PlaySound( ship[char[on_char].ship_ID].thruster_3_sound_ID, 25, 1 )
                Else
                    SetSpriteVisible ( ship[char[on_char].ship_ID].thruster_3_sprite_ID, 0 )
                    StopSound( ship[char[on_char].ship_ID].thruster_3_sound_ID )
                EndIf
                If char[on_char].input_left_up Or char[on_char].input_up `q w
                    SetSpritePhysicsForce( ship[char[on_char].ship_ID].sprite_ID, GetSpriteXByOffset(ship[char[on_char].ship_ID].thruster_4_sprite_ID), GetSpriteYByOffset(ship[char[on_char].ship_ID].thruster_4_sprite_ID), Cos(GetSpriteAngle( ship[char[on_char].ship_ID].thruster_4_sprite_ID )-90)* 1000, Sin(GetSpriteAngle( ship[char[on_char].ship_ID].thruster_4_sprite_ID )-90) * 1000 )
                    SetSpriteVisible ( ship[char[on_char].ship_ID].thruster_4_sprite_ID, 1 )
                    If GetSoundInstances(ship[char[on_char].ship_ID].thruster_4_sound_ID) = 0 Then PlaySound( ship[char[on_char].ship_ID].thruster_4_sound_ID, 25, 1 )
                Else
                    SetSpriteVisible ( ship[char[on_char].ship_ID].thruster_4_sprite_ID, 0 )
                    StopSound( ship[char[on_char].ship_ID].thruster_4_sound_ID )
                Endif
            Else
                `if the player is not in a spaceship, then we need to calculate the gravity forces for the player
                For gravityPointY = 1 To grid_size_y
                    For gravityPointX = 1 To grid_size_x
                        If GetSpriteExists(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x)
                            gravityPointPositionX = GetSpriteXByOffset(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x) + (gravitywellOffset[gravityPointX,gravityPointY,1])
                            gravityPointPositionY = GetSpriteYByOffset(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x) + (gravitywellOffset[gravityPointX,gravityPointY,2])

                            ShipMass = GetSpritePhysicsMass( char[on_char].sprite_ID )

                            GravForce = ((GRAV_CONSTANT*ShipMass*gravitywells[gravityPointX,gravityPointY])/(calculateDistance(GetSpriteXByOffset(char[on_char].sprite_ID), GetSpriteYByOffset(char[on_char].sprite_ID),gravityPointPositionX,gravityPointPositionY )^2))
                            GravForce = GravForce*(gravitywells[gravityPointX,gravityPointY]/ShipMass)

                            GravityX = GravityX + COS(ATANFULL(GetSpriteXByOffset(char[on_char].sprite_ID)-gravityPointPositionX,GetSpriteYByOffset(char[on_char].sprite_ID)-gravityPointPositionY)+90) * (GravForce * GetFrameTime() )
                            GravityY = GravityY + SIN(ATANFULL(GetSpriteXByOffset(char[on_char].sprite_ID)-gravityPointPositionX,GetSpriteYByOffset(char[on_char].sprite_ID)-gravityPointPositionY)+90) * (GravForce * GetFrameTime() )

                        EndIf
                    Next gravityPointX
                Next gravityPointY

                `and we apply the gravity forces to the player
                SetSpritePhysicsForce( char[on_char].sprite_ID, GetSpriteXByOffset(char[on_char].sprite_ID), GetSpriteYByOffset(char[on_char].sprite_ID), GravityX, GravityY)
            EndIf
        Next on_char





        `if the spaceship is in contact with something, another ship, the planet, a pilot
        contact = GetSpriteFirstContact(ship[on_ship].sprite_ID)

        While contact <> 0
            `find out where it's hitting
            cx#=GetSpriteContactWorldX()
            cy#=GetSpriteContactWorldy()
            `and depending on the gforces, throw out particles!
            If ABS(ship[on_ship].gforce_change) > 2 Or ABS(GetSpritePhysicsVelocityX( ship[on_ship].sprite_ID )) > 2 Or ABS(GetSpritePhysicsVelocityY( ship[on_ship].sprite_ID )) > 2
                `I found having about 10 particle emitters is just about right
                `you can increase this if a lot of action is happening and you want particles for it all!
                partcounter = partcounter + 1
                If partcounter > 10
                    partcounter = 1
                EndIf
                If GetParticlesExists( partcounter ) = 0
                    CreateParticles( partcounter, cx#, cy# )
                    SetParticlesSize(partcounter,1.0)
                    SetParticlesMax( partcounter, 1 )
                    SetParticlesVelocityRange( partcounter, 0.1, 0.5 )
                    AddParticlesColorKeyFrame( partcounter, 0, 200, 200, 200, 100 )
                    SetParticlesSize( partcounter, 1 )
                Else
                    ResetParticleCount(partcounter)
                    SetParticlesPosition(partcounter, cx#, cy#)
                EndIf
            EndIf
            contact=GetSpriteNextContact()
        EndWhile

    Next on_ship

    `based on the velocity of the player, rotate the universe
    `this is not physically accurate positioning, but it looks awesome
    RotateCameraLocalY( 1, GetSpritePhysicsVelocityX( char[char].sprite_ID ) / 1000 )
    RotateCameraLocalX( 1, GetSpritePhysicsVelocityY( char[char].sprite_ID ) / 1000 )

    `Place the view on the first character, change this to change where the camera points
    SetViewOffset(  GetSpriteX(char[char].sprite_ID)-(GetVirtualWidth()/2), GetSpriteY(char[char].sprite_ID)-(GetVirtualHeight()/2) )

    `lense flare code
    `figure out where the sun is on the screen
    object_screen_x = GetScreenXFrom3D( GetObjectX(2), GetObjectY(2), GetObjectZ(2) )
    object_screen_y = GetScreenYFrom3D( GetObjectX(2), GetObjectY(2), GetObjectZ(2) )

    `check if any objects (ships only) are obstructing light, if so, we'll reduce the brightness effect
    If GetSpriteInCircle( ship[shipID].sprite_ID, ScreenToWorldX(object_screen_x), ScreenToWorldY(object_screen_y), 1 )
        reduce = 128
    Else
        reduce = 255
    EndIf

    `if the sun is on the screen, and not well outside of the screen
    If object_screen_x > -10 And object_screen_x < 430 And object_screen_y > -10 And object_screen_y < 270 And GetCameraAngleY(1) > -90 And GetCameraAngleY(1) < 90  `if sun is on screen

        `figure out about what percentage away from the center of the screen it is
        percent_x = Abs(screen.center_x - object_screen_x)
        percent_y = Abs(screen.center_y - object_screen_y)
        percent_x = percent_x / screen.center_x
        percent_y = percent_y / screen.center_y

        `and the direction of the flare, imagining a straight line running through the center of the screen and the sun
        direction_vector_x = screen.center_x - object_screen_x
        direction_vector_y = screen.center_y - object_screen_y

        `figure out the length of that line
        distance_of_vector = sqrt((direction_vector_x * direction_vector_x) + (direction_vector_y * direction_vector_y))

        `and render it all
        For flare_ID = 1 To 4
            SetSpritePositionByOffset(flare[flare_ID].sprite_ID,  object_screen_x + ((direction_vector_x / distance_of_vector) * (flare[flare_ID].distance_from_center * percent_x)),  object_screen_y + ((direction_vector_y / (distance_of_vector)) * (flare[flare_ID].distance_from_center * percent_y)))
            SetSpriteVisible(flare[flare_ID].sprite_ID,1)
        Next flare_ID

        `now we determine the brightness of the screen
        brightness = reduce-(distance_of_vector)
        SetSpriteColorAlpha(14, brightness)
        SetSpriteVisible(14,1)
    Else
        `if the sun is off the screen, then don't adjust the brightness
        For flare_ID = 1 To 4
            SetSpriteVisible(flare[flare_ID].sprite_ID,0)
        Next flare_ID
        SetSpriteVisible(14,0)

    EndIf

    `if esc or back is pressed
    If GetRawKeyReleased(27) = 1
        `DELETE ALL THE THINGS
        For gravityPointY = 1 To grid_size_y
            For gravityPointX = 1 To grid_size_x
                If GetSpriteExists(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x)
                    DeleteSprite(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x)
                EndIf
                If GetImageExists(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x)
                    DeleteImage(100+gravityPointX + (gravityPointY*grid_size_x)-grid_size_x)
                Endif
            Next gravityPointX
        Next gravityPointY

        `DELETE ALL THE THINGS
        If GetImageExists(flare[1].image_ID) Then DeleteImage(flare[1].image_ID)
        If GetImageExists(flare[2].image_ID) Then DeleteImage(flare[2].image_ID)
        If GetImageExists(flare[3].image_ID) Then DeleteImage(flare[3].image_ID)
        If GetImageExists(flare[4].image_ID) Then DeleteImage(flare[4].image_ID)
        If GetSpriteExists(flare[1].sprite_ID) Then DeleteSprite(flare[1].sprite_ID)
        If GetSpriteExists(flare[2].sprite_ID) Then DeleteSprite(flare[2].sprite_ID)
        If GetSpriteExists(flare[3].sprite_ID) Then DeleteSprite(flare[3].sprite_ID)
        If GetSpriteExists(flare[4].sprite_ID) Then DeleteSprite(flare[4].sprite_ID)

        If GetImageExists(img_grav_locator) Then DeleteImage(img_grav_locator)
        If GetImageExists(img_grav_needle) Then DeleteImage(img_grav_needle)
        If GetSpriteExists(spr_grav_locator) Then DeleteSprite(spr_grav_locator)
        If GetSpriteExists(spr_grav_needle) Then DeleteSprite(spr_grav_needle)

        If GetImageExists(8) Then DeleteImage(8)
        If GetImageExists(9) Then DeleteImage(9)
        If GetSpriteExists(14) Then DeleteSprite(14)
        If GetObjectExists(1) Then DeleteObject(1)
        If GetObjectExists(2) Then DeleteObject(2)


        `DELETE ALL THE THINGS
        For partcounter = 1 To 10
            If GetParticlesExists( partcounter )
                DeleteParticles( partcounter)
            Endif
        Next

        `comment this out for some fun, ships will not be deleted
        DeleteAllShips()

        `comment this out for some fun, characters inside ships will not be deleted
        DeleteAllCharacters()

        Goto ReturnToTitle
    EndIf


    Sync()
Loop

Function LoadLevel(image_number As Integer, mass As Float)

    CreateMemblockFromImage(1,image_number)

    width = GetMemblockInt(1, 0)
    height = GetMemblockInt(1, 4)
    size = GetMemblockSize(1)

    `we split up the world into 32 same sized chunks. Small worlds have more accurate collision boxes, large worlds are less accurate but the engine can handle it
    grid_size_x = Ceil( width / 32)
    grid_size_y = Ceil( height / 32)

    `we limit the maximum size of the world to 64 tiles
    If grid_size_x > 64 Then grid_size_x = 64
    If grid_size_y > 64 Then grid_size_y = 64

    `calculate the total gravity effect of the level
    gravity_well_width = width / grid_size_x
    gravity_well_height = height / grid_size_y

    `set the mass in case a bad value was passed in
    If mass = 0
        mass = 2
    EndIf

    `initialize the array to store the gravity information
    Dim gravitywells[grid_size_x,grid_size_y] As Float
    Dim gravitywellOffset[grid_size_x,grid_size_y,2] As Float

    x = 0
    y = 0

    `used by the loading screen to show how long it's taking to load. Large levels take a long time!
    time# = Timer()

    `loop through every tile, calculate it's gravity well, calculate the point at which the gravity is centered, and also setup a collision box
    For spriteMapY = 1 To grid_size_y
        For spriteMapX = 1 To grid_size_x
            `copy the tile into its own image, because we render tiles, not the whole image
            `this is because of the physics engine, we have to split up the image to make the collision polygons
            CopyImage( 100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, image_number, (spriteMapX-1)*gravity_well_width, (spriteMapY-1)*gravity_well_height, gravity_well_width, gravity_well_height)

            `we will use this memblock to check if it's a blank tile, and to calculate the total mass
            CreateMemblockFromImage(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x,100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x)
            width = GetMemblockInt(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, 0)
            height = GetMemblockInt(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, 4)
            size = GetMemblockSize(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x)

            `initialize some variables
            gravitywells[spriteMapX,spriteMapY] = 0
            gravitywellOffset[spriteMapX,spriteMapY,1] = 0
            gravitywellOffset[spriteMapX,spriteMapY,2] = 0
            x = 1
            y = 1
            total_gravity_pixels = 0
            for c = 12 to size - 1 step 4
                `this will loops us through all the image data, the format of which is documented in the helpfiles under command CreateMemblockFromImage

                `write gravity values and check for blank tile
                `if the tile is blank all this will be zeros
                If GetMemblockByte(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, c+3) > 0
                    gravitywells[spriteMapX,spriteMapY] = gravitywells[spriteMapX,spriteMapY] + mass
                    total_gravity_pixels = total_gravity_pixels + 1
                    gravitywellOffset[spriteMapX,spriteMapY,1] = gravitywellOffset[spriteMapX,spriteMapY,1] + x
                    gravitywellOffset[spriteMapX,spriteMapY,2] = gravitywellOffset[spriteMapX,spriteMapY,2] + y
                EndIf

                x = x + 1
                If x > width `keep track of the x and y point we're reading
                    x = 1
                    y = y + 1
                EndIf
            next c

            `copy down the center of the gravity point of the tile. For example, if a tile has pixels only on the bottom half
            `then this will calculate the middle of the chunk of pixels, about 3/4 down on the tile
            gravitywellOffset[spriteMapX,spriteMapY,1] = (gravitywellOffset[spriteMapX,spriteMapY,1] / (total_gravity_pixels)) - (gravity_well_width/2)
            gravitywellOffset[spriteMapX,spriteMapY,2] = (gravitywellOffset[spriteMapX,spriteMapY,2] / (total_gravity_pixels)) - (gravity_well_height/2)

            `if the gravity well is massive enough, make a sprite, figure out the physics box
            If gravitywells[spriteMapX,spriteMapY] > 10*mass
                CreateSprite(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, 100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x)
                SetSpriteOffset(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, GetSpriteWidth(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x,)/2, GetSpriteHeight(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x,)/2)
                SetSpritePositionByOffset(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, spriteMapX * gravity_well_width, spriteMapY * gravity_well_height)
                SetSpriteShape( 100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, 3 )
                SetSpritePhysicsOn( 100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x, 1 )
            EndIf

            `delete the memblock as we no longer need it
            DeleteMemblock(100+spriteMapX + (SpriteMapY*grid_size_x)-grid_size_x)

        Next spriteMapX

        `move the camera far away and render a loading screen
        SetViewOffset(10000,10000)
        Print("Launching. T+" + Str(Timer()-time#))
        Sync()

    Next spriteMapY

    `delete this as we no longer need it
    DeleteMemblock(1)


EndFunction

Function DeleteAllShips()
    `DELETE ALL THE THINGS
    For on_ship = 1 To number_of_ships
        DeleteSprite( ship[on_ship].thruster_1_sprite_ID )
        DeleteSprite( ship[on_ship].thruster_2_sprite_ID )
        DeleteSprite( ship[on_ship].thruster_3_sprite_ID )
        DeleteSprite( ship[on_ship].thruster_4_sprite_ID )

        DeleteSound(ship[number_of_ships].thruster_1_sound_ID)
        DeleteSound(ship[number_of_ships].thruster_2_sound_ID)
        DeleteSound(ship[number_of_ships].thruster_3_sound_ID)
        DeleteSound(ship[number_of_ships].thruster_4_sound_ID)

        DeleteSprite(ship[on_ship].sprite_ID)

        DeleteImage(ship[on_ship].image_ID)
        DeleteImage(ship[on_ship].thruster_image_ID)
    Next
EndFunction

Function DeleteAllCharacters()
    `DELETE ALL THE THINGS
    For on_char = 1 To number_of_characters
        DeleteImage(char[number_of_characters].image_ID)
        DeleteSprite(char[number_of_characters].sprite_ID)
    Next

EndFunction


Function LoadShip(filename As String)
    `load a ship using a file that stores our data
    file_ID = OpenToRead( "ships/" + filename )
    If file_ID = 0
        ExitFunction 0
    EndIf

    `increase the number of ships in the game by 1, this is a global value
    number_of_ships = number_of_ships + 1
    `resize the array, this will not delete our earlier entries if any
    Dim ship[number_of_ships] As ship

    `load all the data in and start creating sprites and positioning them
    ship[number_of_ships].image_ID = LoadImage("ships/" + ReadLine( file_ID ))
    ship[number_of_ships].thruster_image_ID = LoadImage("ships/" + ReadLine( file_ID ))

    ship[number_of_ships].passenger_offset_x = ValFloat(ReadLine( file_ID ))
    ship[number_of_ships].passenger_offset_y = ValFloat(ReadLine( file_ID ))

    ship[number_of_ships].sprite_ID = CreateSprite( ship[number_of_ships].image_ID )

    ship[number_of_ships].thruster_1_sprite_ID = CreateSprite( ship[number_of_ships].thruster_image_ID )
    ship[number_of_ships].thruster_2_sprite_ID = CreateSprite( ship[number_of_ships].thruster_image_ID )
    ship[number_of_ships].thruster_3_sprite_ID = CreateSprite( ship[number_of_ships].thruster_image_ID )
    ship[number_of_ships].thruster_4_sprite_ID = CreateSprite( ship[number_of_ships].thruster_image_ID )

    SetSpriteOffset(ship[number_of_ships].sprite_ID, GetSpriteWidth(ship[number_of_ships].sprite_ID)/2,GetSpriteHeight(ship[number_of_ships].sprite_ID)/2)

    SetSpriteOffset(ship[number_of_ships].thruster_1_sprite_ID, GetSpriteWidth(ship[number_of_ships].thruster_1_sprite_ID)/2,0)
    SetSpriteOffset(ship[number_of_ships].thruster_2_sprite_ID, GetSpriteWidth(ship[number_of_ships].thruster_2_sprite_ID)/2,0)
    SetSpriteOffset(ship[number_of_ships].thruster_3_sprite_ID, GetSpriteWidth(ship[number_of_ships].thruster_3_sprite_ID)/2,-1)
    SetSpriteOffset(ship[number_of_ships].thruster_4_sprite_ID, GetSpriteWidth(ship[number_of_ships].thruster_4_sprite_ID)/2,-1)

    SetSpriteAngle(ship[number_of_ships].thruster_1_sprite_ID, ValFloat(ReadLine( file_ID )))
    SetSpriteAngle(ship[number_of_ships].thruster_2_sprite_ID, ValFloat(ReadLine( file_ID )))
    SetSpriteAngle(ship[number_of_ships].thruster_3_sprite_ID, ValFloat(ReadLine( file_ID )))
    SetSpriteAngle(ship[number_of_ships].thruster_4_sprite_ID, ValFloat(ReadLine( file_ID )))

    SetSpritePositionByOffset(ship[number_of_ships].thruster_1_sprite_ID, GetSpriteX(ship[number_of_ships].sprite_ID)+ValFloat(ReadLine( file_ID )),GetSpriteY(ship[number_of_ships].sprite_ID)+ValFloat(ReadLine( file_ID )))
    SetSpritePositionByOffset(ship[number_of_ships].thruster_2_sprite_ID, GetSpriteX(ship[number_of_ships].sprite_ID)+ValFloat(ReadLine( file_ID )),GetSpriteY(ship[number_of_ships].sprite_ID)+ValFloat(ReadLine( file_ID )))
    SetSpritePositionByOffset(ship[number_of_ships].thruster_3_sprite_ID, GetSpriteX(ship[number_of_ships].sprite_ID)+ValFloat(ReadLine( file_ID )),GetSpriteY(ship[number_of_ships].sprite_ID)+ValFloat(ReadLine( file_ID )))
    SetSpritePositionByOffset(ship[number_of_ships].thruster_4_sprite_ID, GetSpriteX(ship[number_of_ships].sprite_ID)+ValFloat(ReadLine( file_ID )),GetSpriteY(ship[number_of_ships].sprite_ID)+ValFloat(ReadLine( file_ID )))

    `load all the physics
    SetSpriteShape( ship[number_of_ships].sprite_ID, 3 )
    SetSpritePhysicsOn( ship[number_of_ships].sprite_ID, 2 )

    SetSpritePhysicsOn( ship[number_of_ships].thruster_1_sprite_ID, 2 )
    SetSpriteShape( ship[number_of_ships].thruster_1_sprite_ID, 0 )
    AddSpriteShapeCircle(ship[number_of_ships].thruster_1_sprite_ID,ValFloat(ReadLine( file_ID )),ValFloat(ReadLine( file_ID )),1)
    SetSpritePhysicsOn( ship[number_of_ships].thruster_2_sprite_ID, 2 )
    SetSpriteShape( ship[number_of_ships].thruster_2_sprite_ID, 0 )
    AddSpriteShapeCircle(ship[number_of_ships].thruster_2_sprite_ID,ValFloat(ReadLine( file_ID )),ValFloat(ReadLine( file_ID )),1)
    SetSpritePhysicsOn( ship[number_of_ships].thruster_3_sprite_ID, 2 )
    SetSpriteShape( ship[number_of_ships].thruster_3_sprite_ID, 0 )
    AddSpriteShapeCircle(ship[number_of_ships].thruster_3_sprite_ID,ValFloat(ReadLine( file_ID )),ValFloat(ReadLine( file_ID )),1)
    SetSpritePhysicsOn( ship[number_of_ships].thruster_4_sprite_ID, 2 )
    SetSpriteShape( ship[number_of_ships].thruster_4_sprite_ID, 0 )
    AddSpriteShapeCircle(ship[number_of_ships].thruster_4_sprite_ID,ValFloat(ReadLine( file_ID )),ValFloat(ReadLine( file_ID )),1)

    `weld the thruster graphics onto the ship
    ship[number_of_ships].thruster_1_joint_ID = CreateWeldJoint( ship[number_of_ships].sprite_ID, ship[number_of_ships].thruster_1_sprite_ID, GetSpriteWidth(ship[number_of_ships].sprite_ID)/2,GetSpriteHeight(ship[number_of_ships].sprite_ID)/2, 0 )
    ship[number_of_ships].thruster_2_joint_ID = CreateWeldJoint( ship[number_of_ships].sprite_ID, ship[number_of_ships].thruster_2_sprite_ID, GetSpriteWidth(ship[number_of_ships].sprite_ID)/2,GetSpriteHeight(ship[number_of_ships].sprite_ID)/2, 0 )
    ship[number_of_ships].thruster_3_joint_ID = CreateWeldJoint( ship[number_of_ships].sprite_ID, ship[number_of_ships].thruster_3_sprite_ID, GetSpriteWidth(ship[number_of_ships].sprite_ID)/2,GetSpriteHeight(ship[number_of_ships].sprite_ID)/2, 0 )
    ship[number_of_ships].thruster_4_joint_ID = CreateWeldJoint( ship[number_of_ships].sprite_ID, ship[number_of_ships].thruster_4_sprite_ID, GetSpriteWidth(ship[number_of_ships].sprite_ID)/2,GetSpriteHeight(ship[number_of_ships].sprite_ID)/2, 0 )

    `Load Sounds
    ship[number_of_ships].thruster_1_sound_ID = LoadSound("sounds/thruster.wav")
    ship[number_of_ships].thruster_2_sound_ID = LoadSound("sounds/thruster.wav")
    ship[number_of_ships].thruster_3_sound_ID = LoadSound("sounds/thruster.wav")
    ship[number_of_ships].thruster_4_sound_ID = LoadSound("sounds/thruster.wav")


    `ExitFunction number_of_ships
EndFunction number_of_ships

Function LoadCharacter(filename As String)
    `load a character that can pilot a ship

    `increase the number of characters by 1, this is a global value
    number_of_characters = number_of_characters + 1
    Dim char[number_of_characters] As character
    char[number_of_characters].image_ID = LoadImage(filename)
    char[number_of_characters].sprite_ID = CreateSprite( char[number_of_characters].image_ID )
    SetSpritePhysicsOn( char[number_of_characters].sprite_ID, 2 )
    SetSpriteShape( char[number_of_characters].sprite_ID, 3 )
    SetSpriteOffset(char[number_of_characters].sprite_ID, GetSpriteWidth(char[number_of_characters].sprite_ID)/2, GetSpriteHeight(char[number_of_characters].sprite_ID)/2)
    SetSpriteDepth(char[number_of_characters].sprite_ID,20)
EndFunction number_of_characters


Function CharacterBoardShip(char As Integer, shipID as Integer)
    `place the character into a ship. She can now control the ship
    SetSpritePositionByOffset(char[char].sprite_ID, GetSpriteX(ship[shipID].sprite_ID)+ship[shipID].passenger_offset_x,GetSpriteY(ship[shipID].sprite_ID)+ship[shipID].passenger_offset_y)
    ship[shipID].passenger_joint_ID = CreateWeldJoint( ship[shipID].sprite_ID, char[char].sprite_ID, GetSpriteWidth(ship[shipID].sprite_ID)/2, GetSpriteHeight(ship[shipID].sprite_ID)/2, 0 )
    char[char].ship_joint_ID = ship[shipID].passenger_joint_ID
    char[char].ship_ID = shipID
    ship[shipID].passenger_ID = char
EndFunction

// From Useful Community Functions : http://forum.thegamecreators.com/?m=forum_view&t=193433&b=41
function calculateDistance(xPosition1#, yPosition1#, xPosition2#, yPosition2#)
	distance# = 0
	b# = 0
	c# = 0
	if xPosition1# > xPosition2#
		b# = xPosition1# - xPosition2#
	elseif xPosition1# < xPosition2#
		b# = xPosition2# - xPosition1#
	endif
	if yPosition1# > yPosition2#
		c# = yPosition1# - yPosition2#
	elseif yPosition1# < yPosition2#
		c# = yPosition2# - yPosition1#
	endif
    distance# = sqrt((b# * b#) + (c# * c#))
endfunction distance#
