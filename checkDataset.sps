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

**** Usage: checkDataset(include = None, exclude = None, tables = True, graphs = False)
**** "include" is an optional argument providing list of strings indicating the names of variables
* that should be included in the analysis. By default, the function will include all variables.
**** "exclude" is an optional argument providing a list of strings indicating the names of vairables 
* that should be excluded from the analysis. By default, the function will not exclude any 
* variables. If you provide both an include list and an exclude list, the function will include all
* variables that are in the include list that are not in the exclude list.
**** "tables" is an optional boolean argument indicating whether you want descriptive tables.
* If you omit this argument then the tables will be provided.
**** "graphs" is an optional boolean argument indicating whether you want to see graphs of each
* variable's distribution. If you omit this argument then the graphs will not be provided.

BEGIN PROGRAM PYTHON3.
import spss, spssaux, tempfile, os, sys, SpssClient

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
          if (float(result[0]) != 0 and len(result) > 2):
               return float((result[2]))

def _titleToPane():
    """See titleToPane(). This function does the actual job"""
    outputDoc = SpssClient.GetDesignatedOutputDoc()
    outputItemList = outputDoc.GetOutputItems()
    textFormat = SpssClient.DocExportFormat.SpssFormatText
    filename = tempfile.mktemp() + ".txt"
    for index in range(outputItemList.Size()):
        outputItem = outputItemList.GetItemAt(index)
        if outputItem.GetDescription() == "Page Title":
            outputItem.ExportToDocument(filename, textFormat)
            with open(filename) as f:
                outputItem.SetDescription(f.read().rstrip())
            os.remove(filename)
    return outputDoc

def titleToPane(spv=None):
    """Copy the contents of the TITLE command of the designated output document
    to the left output viewer pane"""
    try:
        outputDoc = None
        SpssClient.StartClient()
        if spv:
            SpssClient.OpenOutputDoc(spv)
        outputDoc = _titleToPane()
        if spv and outputDoc:
            outputDoc.SaveAs(spv)
    except:
        print("Error filling TITLE in Output Viewer [%s]" % sys.exc_info()[1])
    finally:
        SpssClient.StopClient()
               
def checkDataset(include = None, exclude = None, tables = True, graphs = False):
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
                print("{0} is continuous with no valid cases".format(var))
    
#### Categorical vars
    for var in catList:
        spss.Submit("title '{0}'.".format(var))
# Descriptives tables
        if (tables == True):
            submitstring = """FREQUENCIES VARIABLES={0}
  /ORDER=ANALYSIS.""".format(var)
            spss.Submit(submitstring)
# Frequency plots
        if (graphs == True):
            submitstring = """GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES={0} COUNT()[name="COUNT"] MISSING=LISTWISE
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  INLINETEMPLATE=
["<addDataLabels labelLocationVertical='positive'>" +
"<style color='#000000' font-size='8pt' font-style='regular' fontweight='regular' number='0' padding='3px' visible='visible'/>" +
"<labeling variable='count'></labeling></addDataLabels>" ].
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: {0}=col(source(s), name("{0}"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  GUIDE: axis(dim(1), label("{0}"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: text.title(label("Simple Bar Count of {0}"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval(position({0}*COUNT), shape.interior(shape.square))
END GPL.""".format(var)
            spss.Submit(submitstring)

#### Continuous vars
    for var in conList:
        spss.Submit("title '{0}'.".format(var))
# Descriptive tables        
        if (tables == True): 
            submitstring = """DESCRIPTIVES VARIABLES={0}
  /STATISTICS=MEAN STDDEV MIN MAX.""".format(var)        
            spss.Submit(submitstring)
# Graphs
        if (graphs == True):
            submitstring = """* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES={0} MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: {0}=col(source(s), name("{0}"))
  GUIDE: axis(dim(1), label("{0}"))
  GUIDE: axis(dim(2), label("Frequency"))
  GUIDE: text.title(label("Simple Bar of {0}"))
  ELEMENT: interval(position(summary.count(bin.rect({0}))), shape.interior(shape.square))
END GPL.""".format(var)
            spss.Submit(submitstring)

    titleToPane()            
end program python.

********
* Version History
********
* 2020-11-08 Created
* 2020-11-09 Fixed an error with list assignment/copying 
* 2022-08-21 Added tables and graph options
