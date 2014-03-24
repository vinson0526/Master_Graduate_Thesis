#include <iostream>

/* run this program using the console pauser or add your own getch, system("pause") or input loop */
#include "HPSSClass.h"
#include <string>
#include <cstdlib>
static const unsigned short numberOfArg = 4;
using namespace std;

int main(int argc, char** argv)
{
	if (argc < numberOfArg)
	{
		cout << "the number of args is wrong" << endl;
		return 0;
	}

	string inputFileName = argv[1];
	string HFileName = argv[2];
	string PFileName = argv[3];
	
	double alpha = 0.950;
	double gamma = 0.20;
	int frameSize = 512;
	int iterNum = 10;
	
	
	for(int i = 4; i < argc; i++)
	{
		if(argv[i][0] == '-' && argv[i][2] == '\0')
		{
			switch(argv[i][1])
			{
				case 'a':
					if(i + 1 < argc)
					{
						alpha = atof(argv[i + 1]);
					}
					break;
				case 'g':
					if(i + 1 < argc)
					{
						gamma = atof(argv[i + 1]);
					}
					break;
				case 'f':
					if(i + 1 < argc)
					{
						frameSize = atoi(argv[i + 1]);
					}
					break;
				case 'i':
					if(i + 1 < argc)
					{
						iterNum = atoi(argv[i + 1]);
					}
					break;
				default:
					break;
			}
		}
	}

	HPSSClass hpss(inputFileName, alpha, gamma, frameSize, iterNum);
	hpss.generateHP(HFileName, PFileName);

	return 0;
}
