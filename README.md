# checkDataset
The purpose of this function is to obtain some basic information about the variables in the dataset to see if their distributions are falling into expected ranges. It first determines whether variables should be treated categorically or continuously based on whether they have value labels or not. For variables that have value labels, the function provides a frequency distribution. For variables without value labels, the function provides descriptive statistics. You can identify variables that you either want to include in or exclude from the analysis.

## Usage
**checkDataset(include = None, exclude = None, tables = True, graphs = False)**
* "include" is an optional argument providing list of strings indicating the names of variables that should be included in the analysis. By default, the function will include all variables.
* "exclude" is an optional argument providing a list of strings indicating the names of vairables that should be excluded from the analysis. By default, the function will not exclude any variables. If you provide both an include list and an exclude list, the function will include all variables that are in the include list that are not in the exclude list.
* "tables" is an optional boolean argument indicating whether you want descriptive tables. If you omit this argument then the tables will be provided.
* "graphs" is an optional boolean argument indicating whether you want to see graphs of each variable's distribution. If you omit this argument then the graphs will not be provided.

## Example
**checkDataset(include = ["Age", "YearsEducation", "YearsExperience", "Gender", "Race"],  
exclude = ["Race"],
tables = True,
graphs = True)**
* In this example, we assume that Age, YearsEducation, and YearsExperience are continuous variables without value labels, while Gender and Race are categorical variables with value labels.
* The function will provide descriptive statistics for Age, YearsEducation, and YearsExperience. It will provide frequencies for Gender.
* The function will provide histograms for continuous variables and bar plots for Gender.
* No information about Race is provided because it is in the exclude list. Inclusion in the exclude list overrides inclusion in the include list.

This and other SPSS Python Extension functions can be found at http://www.stat-help.com/python.html
