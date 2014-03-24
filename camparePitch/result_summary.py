#coding in utf-8
#作用：每三行中取第二行中的数  xxx/yyy ,将所有xxx相加，所有yyy相加
#参数，待处理文件
#结果文件，为待处理文件夹 目录下 cut_and_plus_result/ cut_and_plus_待处理文件名
import sys,os,string

#inputdir = sys.argv[1]
output = sys.argv[2]
#files = os.listdir(inputdir)

outputdir = output+'\\'+'cut_and_plus_result'

if not os.path.isdir(outputdir):
    os.makedirs(outputdir)

#for file in files:
#inputfilename = inputdir + '\\' + file
inputfilename = sys.argv[1]
f1 = open(inputfilename,'r')
lines = f1.readlines()
#print type(lines)
l = len(lines)/5
cut_string1 = []
cut_string1_1 = []
cut_string2 = []
cut_string2_2 = []
    
#outputfilename = outputdir+'\\'+'cut_and_plus'+file
outputfilename = outputdir+'\\'+'cut_and_plus'
f2 = open(outputfilename,'w')
for index in range(l):
	cut_string1.append(lines[5*index+1].strip('\n').split(':'))
	cut_string2.append(lines[5*index+3].strip('\n').split(':'))
for index in range(l):
	cut_string1_1.append(cut_string1[index][1].replace(" ","").split('/'))
	cut_string2_2.append(cut_string2[index][1].replace(" ","").split('/'))

one = 0
two = 0
three = 0
for index in range(l):
	one = one + int(cut_string1_1[index][0])
	two = two + int(cut_string1_1[index][1])
	three = three +int(cut_string2_2[index][0])
	#f2.write(str(one))
	f2.write(cut_string1_1[index][0])
	f2.write(' --- ')
	f2.write(cut_string1_1[index][1])
	f2.write(' --- ')
	f2.write(cut_string2_2[index][0])
	#f2.write(str(two))
	f2.write('\n')
f2.write(str(one))
f2.write(' --- ')
f2.write(str(two))
f2.write(' --- ')
f2.write(str(three))
f2.close()

