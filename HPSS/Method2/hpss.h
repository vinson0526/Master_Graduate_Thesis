#ifndef HPSS_H
#define HPSS_H

#include <vector>
#include <string>
#include <cmath>
#include <iomanip>
#include <fstream>
#include <iostream>

using namespace std;
class HPSS
{
public:
	HPSS(){};
	HPSS(string fileNameCome, int frameSizeCome, int maxIterCome = 500, double gammaCome = 0.5, double sigmaHCome = 0.3, double sigmaPCome = 0.3);
	~HPSS();
	
	void computeHP(string HFileName, string PFileName);
	
private:
	void method1();
	void method2();
	void initial();
	void computeABC();
	void computeM();
	vector<vector<double>> W;
	vector<vector<double>> H;
	vector<vector<double>> P;
	vector<vector<double>> mH;
	vector<vector<double>> mP;
	
	
	double aH;
	double aP;
	vector<vector<double>> bH;
	vector<vector<double>> bP;
	vector<vector<double>> cH;
	vector<vector<double>> cP;
	double alpha;
	double gamma;
	double sigmaH2;
	double sigmaP2;
	double Q;
	
	string fileName;
	int frameSize;
	int frameNum;
	
	int maxIter;

};

#endif
