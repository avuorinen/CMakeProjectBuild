#include <SDL.h> 
#include <lib.h>

int main(int, char**)
{
	SDL_Init(SDL_INIT_EVERYTHING);
	SDL_Log("Hello, From Android!");
	SDL_Log(HelloWorld());
	SDL_Quit();
	return 0;
}