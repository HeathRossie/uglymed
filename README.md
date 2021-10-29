# uglymed
Process and analyze behavioral data from MED outputs


1) import functions
devtools::source_url("https://raw.githubusercontent.com/HeathRossie/uglymed/main/uglymed.R")

If you have not installed devtools package, run
install.packages("devtools")

2) read data 
MED output is ugly. You may face with text file like this.

![Test Image 6](https://user-images.githubusercontent.com/17682330/139409611-997d1d3b-af83-4521-91a2-191bbcf4ed6c.png)

This is really ugly, at least, for people familiar with programming language. 
read.med() package is utility function to read the med output as a data frame.

d = read.med(file, rft_indicator, scale=NULL, remove=NULL, remove_initial=NULL)

file : file name, should be character
rft_indicator : number indicating rft, which should be removed for response time series
scale : numeric, scaling for desirable units (for example data unit is 10ms, scaling 1/100 prduces unit sec)
remove : int, remove data 
remove_initial : integer (N), latest N data is used, initial all_data_length - N were removed

For example, "0.2" indicates the reinforced response in the above picture. Thus,

d = read.med(file, rft_indicator=0.2)

The "scale" argument is optional, but rescale the time by dividing by provided value. 
For example, if the data is stored 10ms time-unit, scale=100 provides the secs as time-units. This should be determined according to your recording conditions.

d = read.med(file, rft_indicator=0.2, scale=100)

The "remove" specify data exclusion. If the 2nd subject is not needed, write "remove=2" for instead. 
The "remove_initial" is used to exclude some of initial data. This option is implemented because some experimenters want to test by pushing lever by his-/herself, and these data are stored in the ouput files. In nutshell, if you want to analyze data from 16 individual, but the file contains more than 16 subjects due to such testing, run

d = read.med(file, rft_indicator=0.2, scale=100, remove_initial=16)


Then, you can get data frame like this:

![Test Image 6](https://user-images.githubusercontent.com/17682330/139412163-199fece3-b079-4244-9189-30b53f71f32b.png)



3) import several data


The read.med function reads one text file, but you may want to read all the files you have in your folder. Simply, use read.med.all() function.

files = list.files(pattern="txt")
d = read.med.all(files, rft_indicator=0.2, scale = 100,remove_initial=16)

The read.med.all() read all the text files and combine as tidy data frame. Then, your analysis truely starts.


4) estimate bout parameter
Bout-pause response pattern is fancy analysis. You should definitely do if you have operant response dataset.
Anyway, the uglymed allows you to perform bout-pause analysis by simply running

estimate_bout(irt)

The function returns three parameters in data frame: bout length, bout initiation rates, and within-bout response rates
![Test Image 6](https://user-images.githubusercontent.com/17682330/139412452-3efba734-d974-431c-9bc1-cd78593cb590.png)








