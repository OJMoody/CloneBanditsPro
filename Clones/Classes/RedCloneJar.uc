//=============================================================================
// RedCloneJar.
//=============================================================================
class RedCloneJar extends CloneJar;

#exec OBJ LOAD FILE=XGameShaders.utx
#exec OBJ LOAD FILE=XGameShaders2004.utx
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
     DrawScale=0.300000
     Skins(0)=Shader'CS_CloneItems_T.CloneJar.JarShader'
     Skins(1)=Texture'CS_CloneItems_T.CloneJar.CloneJarRedNoAlpha'
     Skins(2)=Shader'CS_CloneItems_T.CloneJar.JarStripeRed'
}
