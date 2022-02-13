* Encoding: UTF-8.
* checkDataset function
* by Jamie DeCoster

* The purpose of this function is to obtain some basic information about the variables in the 
* dataset to see if their distributions are falling into expected ranges. It first determines 
* whether variables should be treated categorically or continuously based on whether they
* have value labels or not. For variables that have value labels, the function provides a
* frequency distribution. For variables without value labels, the function provides 
* descriptive statistics. You can identify variables that you either want to include in or
* exclude from the analysis.

**** Usage: checkDataset(include = None, exclude = None)
**** "include" is an optional argument providing list of strings indicating the names of variables
* that should be included in the analysis. By default, the function will include all variables.
**** "exclude" is an optional argument providing a list of strings indicating the names of vairables 
* that should be excluded from the analysis. By default, the function will not exclude any 
* variables. If you provide both an include list and an exclude list, the function will include all
* variables that are in the include list that are not in the exclude list.

begin program python.
import spss, spssaux

def descriptive(variable, stat):
# Valid values for stat are MEAN STDDEV MINIMUM MAXIMUM
# SEMEAN VARIANCE SKEWNESS SESKEW RANGE
# MODE KURTOSIS SEKURT MEDIAN SUM VALID MISSING
# VALID returns the number of cases with valid values, and MISSING returns
# the number of cases with missing values

     if (stat.upper() == "VALID"):
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /ORDER=ANALYSIS."
          freqError = 0
          handle,failcode=spssaux.CreateXMLOutput(
          	cmd,
          	omsid="Frequencies",
          	subtype="Statistics",
          	visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
          	handle,
          	tableSubtype="Statistics",
          	cellAttrib="text")
          if (len(result) > 0):
               return int(result[0])
          else:
               return(0)

     elif (stat.upper() == "MISSING"):
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /ORDER=ANALYSIS."
          handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
		visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
          return int(result[1])
     else:
          cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /STATISTICS="+stat+"\n\
  /ORDER=ANALYSIS."
          handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
     		visible=False)
          result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
          if (float(result[0]) <> 0 and len(result) > 2):
               return float((result[2]))
               
def checkDataset(include = None, exclude = None):
# Create list of variables in data set
    spssVars = []
    for varnum in range (spss.GetVariableCount()):
        spssVars.append(spss.GetVariableName(varnum).upper())

# Obtain list of variables for processing
    if (include == None):
        include = spssVars[:]
    else:
        for t in range(len(include)):
            include[t] = include[t].upper()
    
    if (exclude == None):
        exclude = []
    for t in range(len(exclude)):
        exclude[t] = exclude[t].upper()

    for var in exclude:
        if var in include:
            include.remove(var)

# Obtain lists of categorical and continuous variables
# Categorical vars are those with value labels (can be string or numeric)
# Continuous vars are numeric vars without value labels
# Strings without labels are excluded    
    catList = []
    conList = []
    sDict = spssaux.VariableDict()
    for var in include:
        i = spssVars.index(var)
        if (len(sDict[i].ValueLabels) > 0):
            catList.append(var)
        elif(spss.GetVariableType(i) == 0):
            if (descriptive(var, "VALID") > 0):
                conList.append(var)
            else:
                print "{0} is continuous with no valid cases".format(var)
    
# Present frequencies for categorical vars
    for var in catList:
        print "***** {0} *****".format(var)
        submitstring = """FREQUENCIES VARIABLES={0}
  /ORDER=ANALYSIS.""".format(var)
        spss.Submit(submitstring)

# Present desriptives for continuous vars
    for var in conList:
        print "***** {0} *****".format(var)    
        submitstring = """DESCRIPTIVES VARIABLES={0}
  /STATISTICS=MEAN STDDEV MIN MAX.""".format(var)        
        spss.Submit(submitstring)

end program python.

********
* Version History
********
* 2020-11-08 Created
* 2020-11-09 Fixed an error with list assignment/copying 
