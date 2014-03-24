import os
import gzip
def compare(ground_true_dir, track_value_dir, error):
	true_files = []
	track_files = []
	for list_true_file in os.listdir(ground_true_dir):
		path = os.path.join(ground_true_dir, list_true_file)
		true_files.append(path)
	for list_track_file in os.listdir(track_value_dir):
		path = os.path.join(track_value_dir, list_track_file)
		track_files.append(path)
	for i in xrange(len(true_files)):
		os.system('E:\\Code\\Dev-C++\\camparePitch\\camparePitch.exe ' + true_files[i] + ' ' + track_files[i] + ' ' + error + ' >>E:\\ZZZZZ\\result')
	
	
	
	'''
	list_true_file = os.walk(ground_true_dir)
	list_track_file = os.walk(track_value_dir)
	for true_root, track_root, true_dirs, track_dirs, true_files, track_files in zip(list_true_file, list_track_file):
		print 1
		for true_file, track_file in zip(true_files, track_files):
			print 2
			os.system('E:\Code\Dev-C++\camparePitch\camparePitch.exe ' + os.path.join(true_root, true_file) + ' ' + os.path.join(track_root, track_files) + ' >>E:/ZZZZZ/result')
	'''		
			
if __name__ == '__main__':
	compare("E:\\ZZZZZ\\PitchLabel", "E:\\ZZZZZ\\track", '1')