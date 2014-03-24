#include "HPSSClass.h"
using namespace std;

HPSSClass::HPSSClass(string filenameCome, double alphaCome, double gammaCome, int frameSizeCome, int iterNumCome) :
fileName(filenameCome), alpha(alphaCome), gamma(gammaCome), frameSize(frameSizeCome), iterNum(iterNumCome)
{
	readFFT();
}

void HPSSClass::readFFT()
{
	if(checkArgs())
	{
		cout << "start initial!" << endl;
		ifstream originalFreq;
		double tempFreqValue = 0.0;
		originalFreq.open(fileName);
		vector<double> tempFrame, tempFrameH, tempFrameP, tempFramei;
		int countSize = 0;
		while (originalFreq >> tempFreqValue)
		{
			tempFreqValue = pow(tempFreqValue, 2);
			tempFreqValue = pow(tempFreqValue, alpha);
			countSize++;
			tempFrame.push_back(tempFreqValue);
			tempFrameH.push_back(tempFreqValue * 0.5);
			tempFrameP.push_back(tempFreqValue * 0.5);
			tempFramei.push_back(tempFreqValue * 0.5);
			if(countSize == frameSize)
			{
				signal.push_back(tempFrame);
				signalH.push_back(tempFrameH);
				signalP.push_back(tempFrameP);
				iterK.push_back(tempFramei);
				countSize = 0;
				tempFrame.clear();
				tempFrameH.clear();
				tempFrameP.clear();
				tempFramei.clear();
			}
		}
		frameNum = signal.size();
		originalFreq.close();
		cout << "initial done!" << endl;
	}
}

void HPSSClass::compK()
{
	//cout << "start comp!" << endl;
	double Htag = 0.0, Ptag = 0.0;
	for (int i = 0; i < frameNum; i++)
	{
		for (int j = 0; j < frameSize; j++)
		{
			if (i == 0)
				Htag = (0 - 2 * signalH[i][j] + signalH[i + 1][j]) / 4;
			else if (i == frameNum - 1)
				Htag = (signalH[i - 1][j] - 2 * signalH[i][j] + 0) / 4;
			else
				Htag = (signalH[i - 1][j] - 2 * signalH[i][j] + signalH[i + 1][j]) / 4;
			if (j == 0)
				Ptag = (0 - 2 * signalP[i][j] + signalP[i][j + 1]) / 4;
			else if (j == frameSize - 1)
				Ptag = (signalP[i][j - 1] - 2 * signalP[i][j] + 0) / 4;
			else
				Ptag = (signalP[i][j - 1] - 2 * signalP[i][j] + signalP[i][j + 1]) / 4;
			iterK[i][j] = gamma * Htag - (1 - gamma) * Ptag;
		}
	}
	//cout << "comp done!" << endl;
}

void HPSSClass::iterHandP()
{
	//cout << "start hand!" << endl;
	for (int i = 0; i < frameNum; i++)
	{
		for (int j = 0; j < frameSize; j++)
		{
			signalH[i][j] = min(max(signalH[i][j] + iterK[i][j], 0.0), signal[i][j]);
			signalP[i][j] = signal[i][j] - signalH[i][j];
		}
	}
	//cout << "hand done!" << endl;
}

void HPSSClass::lastHandP()
{
	//cout << "last hand!" << endl;
	for (int i = 0; i < frameNum; i++)
	{
		for (int j = 0; j < frameSize; j++)
		{
			if (signalH[i][j] < signalP[i][j])
			{
				signalH[i][j] = 0;
				signalP[i][j] = pow(signal[i][j], 0.5 / alpha);
			}
			else
			{
				signalP[i][j] = 0;
				signalH[i][j] = pow(signal[i][j], 0.5 / alpha);
			}
		}
	}
	//cout << "last hand done!" << endl;
}


//ouput P&H files a frame per line
void HPSSClass::generateHP(string HFileName, string PFileName)
{
	if(!checkArgs())
		return;
	cout << "start generate!" << endl;
	for (int i = 0; i < iterNum; i++)
	{
		compK();
		iterHandP();
	}
	lastHandP();
	ofstream HFreq, PFreq;
	HFreq.open(HFileName, ios::trunc);
	PFreq.open(PFileName, ios::trunc);
	if (!HFreq || !PFreq)
	{
		cout << "can not open output files!" << endl;
		return;
	}
	for (int i = 0; i < frameNum; i++)
	{
		int j = 0;
		for (; j < frameSize - 1; j++)
		{
			HFreq << setprecision(9) << signalH[i][j] << '\t';
			PFreq << setprecision(9) << signalP[i][j] << '\t';
		}
		HFreq << setprecision(9) << signalH[i][j] << '\n';
		PFreq << setprecision(9) << signalP[i][j] << '\n';
	}
	HFreq.close();
	PFreq.close();
	cout << "generate done!" << endl;
}


//check args' legality
inline bool HPSSClass::checkArgs()
{
	if(lessZero(alpha) || lessZero(gamma) || frameSize <= 0 || iterNum <= 0)
	{
		cout << "wrong args" << endl;
		return false;
	}
	return true;
}


//return double value less than zero
inline bool HPSSClass::lessZero(double a)
{
	if(a - 0 > 0.00001)
	{
		return false;
	}
	else
	{
		return true;
	}
}
