#include "hpss.h"

HPSS::HPSS(string fileNameCome,  int frameSizeCome, int maxIterCome, double gammaCome, double sigmaHCome, double sigmaPCome):
	fileName(fileNameCome), frameSize(frameSizeCome), gamma(gammaCome), sigmaH2(sigmaHCome * sigmaHCome), sigmaP2(sigmaPCome * sigmaPCome), maxIter(maxIterCome)
{
//	W = new vector<vector<double>>;
//	H = new vector<vector<double>>;
//	P = new vector<vector<double>>;
//	mH = new vector<vector<double>>;
//	mP = new vector<vector<double>>;
//	bH = new vector<vector<double>>;
//	bP = new vector<vector<double>>;
//	cH = new vector<vector<double>>;
//	cP = new vector<vector<double>>;
	initial();
}

HPSS::~HPSS()
{
//	delete W;
//	delete H;
//	delete P;
//	delete mH;
//	delete mP;
//	delete bH;
//	delete bP;
//	delete cH;
//	delete cP;
}

void HPSS::initial()
{
	cout << "start initial!" << endl;
	ifstream originalFreq;
	double tempFreqValue = 0.0;
	vector<double> tempFrame, tempFrameH, tempFrameP, tempOther;
	int countSize = 0;
	
	originalFreq.open(fileName);
	//originalFreq >> frameSize;
	while(originalFreq >> tempFreqValue)
	{
		tempFreqValue = pow(tempFreqValue, 2);
		countSize++;
		tempFrame.push_back(tempFreqValue);
		tempFrameH.push_back(tempFreqValue * 0.5);
		tempFrameP.push_back(tempFreqValue * 0.5);
		tempOther.push_back(0.0);
		
		if(countSize == frameSize)
		{
			W.push_back(tempFrame);
			H.push_back(tempFrameH);
			P.push_back(tempFrameP);
			mH.push_back(tempOther);
			mP.push_back(tempOther);
			bH.push_back(tempOther);
			bP.push_back(tempOther);
			cH.push_back(tempOther);
			cP.push_back(tempOther);
			
			countSize = 0;
			
			tempFrame.clear();
			tempFrameH.clear();
			tempFrameP.clear();
			tempOther.clear();
		}
	}
	frameNum = W.size();
	originalFreq.close();
	
	aH = 2.0 / sigmaH2 + 2;
	aP = 2.0 / sigmaP2 + 2;
	
	cout << "initial done!" << endl;
}

void HPSS::computeABC()
{
	for(int i = 0; i != frameNum; i++)
	{

		for(int j = 0; j != frameSize; j++)
		{
			if(i == 0)
			{
				bH.at(i)[j] = sqrt(H.at(i + 1)[j]) / sigmaH2;
			}
			else if(i == frameNum - 1)
			{
				bH.at(i)[j] =sqrt(H.at(i - 1)[j]) / sigmaH2;
			}
			else
			{
				bH.at(i)[j] = (sqrt(H.at(i - 1)[j]) + sqrt(H.at(i + 1)[j])) / sigmaH2;
			}
			if(j == 0)
			{
				bP.at(i)[j] = sqrt(P.at(i)[j + 1]) / sigmaP2;
			}
			else if(j == frameSize - 1)
			{
				bP.at(i)[j] = sqrt(P.at(i)[j - 1]) / sigmaP2;
			}
			else
			{
				bP.at(i)[j] = (sqrt(P.at(i)[j - 1]) + sqrt(P.at(i)[j + 1])) / sigmaP2;
			}
			cH.at(i)[j] = 2 * mH.at(i)[j] * W.at(i)[j];
			cP.at(i)[j] = 2 * mP.at(i)[j] * W.at(i)[j];
		}
	}
}

void HPSS::computeM()
{
	for(int i = 0; i != frameNum; i++)
	{
		for(int j = 0; j != frameSize; j++)
		{
			mH.at(i)[j] = H.at(i)[j] / (H.at(i)[j] + P.at(i)[j]);
			mP.at(i)[j] = 1 - mH.at(i)[j];
		}
	}
}

void HPSS::computeHP(string HFileName, string PFileName)
{
	for(int k = 0; k != maxIter; k++)
	{
		cout << "k: " << k << endl;
		computeM();
		computeABC();
		for(int i = 0; i != frameNum; i++)
		{
			for(int j = 0; j != frameSize; j++)
			{
				H.at(i)[j] = pow((bH.at(i)[j] + sqrt(bH.at(i)[j] * bH.at(i)[j] + 4 * aH * cH.at(i)[j])) / 2 / aH, 2.0);
				P.at(i)[j] = pow((bP.at(i)[j] + sqrt(bP.at(i)[j] * bP.at(i)[j] + 4 * aP * cP.at(i)[j])) / 2 / aP, 2.0);
			}
		}
		double temp1 = 0.0, temp2 = 0.0, temp3 = 0.0, temp4 = 0.0;
		for(int i = 0; i != frameNum; i++)
		{
			for(int j = 0; j != frameSize; j++)
			{
				temp1 = temp1 - mP[i][j] * W[i][j] * log10(mP[i][j] * W[i][j] / P[i][j]);
				temp2 = temp2 - mH[i][j] * W[i][j] * log10(mH[i][j] * W[i][j] / H[i][j]);
				if(j == 0)
				{
					temp3 = temp3 - pow(0 - sqrt(P[i][j]), 2.0) / sigmaP2;
				}
				else
				{
					temp3 = temp3 - pow(sqrt(P[i][j - 1]) - sqrt(P[i][j]), 2.0) / sigmaP2;
				}
				if(i == 0)
				{
					temp4 = temp4 - pow(0 - sqrt(H[i][j]), 2.0) / sigmaH2;
				}
				else
				{
					temp4 = temp4 - pow(sqrt(H[i - 1][j]) - sqrt(H[i][j]), 2.0) / sigmaH2;
				}
			}
		}
		Q = temp1 + temp2 + temp3 + temp4;
		cout << "Q: " << Q << endl;
	}
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
			HFreq << setprecision(5) << H.at(i)[j] << '\t';
			PFreq << setprecision(5) << P.at(i)[j] << '\t';
		}
		HFreq << setprecision(5) << H.at(i)[j] << '\n';
		PFreq << setprecision(5) << P.at(i)[j] << '\n';
	}
	HFreq.close();
	PFreq.close();
}
