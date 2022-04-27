//=============================================================================
// BlueCloneJar.
//=============================================================================
class BlueCloneJar extends CloneJar;

#exec OBJ LOAD FILE=XGameShaders.utx
#exec OBJ LOAD FILE=TeamSymbols_UT2003.utx

simulated function PostBeginPlay()
{    
    Super.PostBeginPlay();  
    
	// TODO_CL: update clone jar animations with custom ones
    //LoopAnim('flag',0.8);
    //SimAnim.bAnimLoop = true;  
}

defaultproperties
{
     TeamNum=1
     LightHue=130
     DrawScale=0.300000
}
