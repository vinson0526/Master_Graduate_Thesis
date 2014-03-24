#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>
using namespace std;

int main(int argc, char** argv)
{
	if(argc != 4)
	{
		cout << "miss para!" << endl;
		return 0;
	}
	fstream ground_true, pitch_track;
	cout << argv[1] << endl;
	ground_true.open(argv[1]);
	pitch_track.open(argv[2]);
	double error = atof(argv[3]);
	double true_value = 0.0;
	double track_value;
	int count_all = 0, count_right = 0, count_octave = 0;
	while(ground_true >> true_value)
	{
		pitch_track >> track_value;
		//cout << "true_value: " << true_value << endl;
		//cout << "track_value: " << track_value << endl;
		if(abs(true_value - 0) < 0.0001 )
		{
			continue;
		}
		else
		{
			count_all++;
			if(abs(true_value - track_value) <= error)
			{
				count_right++;
			}
			else if(abs(true_value - 12 - track_value) <= error || abs(true_value + 12 - track_value) <= error)
			{
				count_octave++;
			}
		}
	}
	cout << "correct number: " << count_right << "/" << count_all << endl;
	cout << "correct rate: " << static_cast<double>(count_right) / count_all * 100 << "%" << endl;
	cout << "octave error: " << count_octave << "/" << count_all << endl;
	cout << "octave rate: " << static_cast<double>(count_octave) / count_all * 100 << "%" << endl;
}
