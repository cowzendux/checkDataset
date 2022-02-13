# checkDataset
The purpose of this function is to obtain some basic information about the variables in the dataset to see if their distributions are falling into expected ranges. It first determines whether variables should be treated categorically or continuously based on whether they have value labels or not. For variables that have value labels, the function provides a frequency distribution. For variables without value labels, the function provides descriptive statistics. You can identify variables that you either want to include in or exclude from the analysis.

## Usage
**checkDataset(include = None, exclude = None)**
* "include" is an optional argument providing list of strings indicating the names of variables that should be included in the analysis. By default, the function will include all variables.
* "exclude" is an optional argument providing a list of strings indicating the names of vairables that should be excluded from the analysis. By default, the function will not exclude any variables. If you provide both an include list and an exclude list, the function will include all variables that are in the include list that are not in the exclude list.
