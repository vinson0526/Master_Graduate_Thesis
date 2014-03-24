#pragma once
#ifndef _HPSSCLASS_H_
#define _HPSSCLASS_H_

#include <vector>
#include <string>
#include <fstream>
#include <cmath>
#include <iostream>
#include <iomanip>
using namespace std;
class HPSSClass
{
public:
	HPSSClass(string filenameCome, double alphaCome = 0.95, double gammaCome = 0.2, int frameSizeCome = 512, int iterNumCome = 5);
	~HPSSClass(){};
	void generateHP(string HFileName, string PFileName);
private:
	void readFFT();
	void compK();
	void iterHandP();
	void lastHandP();
	inline bool checkArgs();
	inline double max(double a, double b){ return a > b ? a : b; };
	inline double min(double a, double b){ return a < b ? a : b; };
	inline bool lessZero(double a);

	vector<vector<double> > signal;
	vector<vector<double> > signalH;
	vector<vector<double> > signalP;
	vector<vector<double> > iterK;

	string fileName;
	double alpha;
	double gamma;
	int frameSize;
	int frameNum;
	int iterNum;
};

#endif
