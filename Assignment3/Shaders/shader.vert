uniform mat4 mvm;
uniform mat4 proj;

void main()
{
	gl_Position = proj * mvm * gl_Vertex;
}