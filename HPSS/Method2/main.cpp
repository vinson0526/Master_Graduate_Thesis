#include <iostream>
#include <string>
#include <cstdlib>
#include "HPSS.h"
using namespace std;
/* run this program using the console pauser or add your own getch, system("pause") or input loop */

int main(int argc, char** argv) {
	
	if(argc < 5)
	{
		cout << "wrong arg number, ori_path, h_path, p_path, frame_size, iter_number!";
		return 0;
	}
	
	string inputFileName = argv[1];
	string HFile = argv[2];
	string PFile = argv[3];
	int frameSize = atoi(argv[4]);
	int iter = 10;
	if(argc >= 6)
	{
		iter = atoi(argv[5]);
	}
	
	
	//cout << inputFileName << endl;
	
	HPSS dotest(inputFileName, frameSize, iter);
	dotest.computeHP(HFile, PFile);
	
	return 0;
}
