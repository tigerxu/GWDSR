fileToExe = HYPHY_LIB_DIRECTORY + "TemplateBatchFiles" + DIRECTORY_SEPARATOR + "GARDProcessor.bf";
 
/* the options passed to the GUI are encoded here */
inputRedirect = {};

	inputRedirect [ "01" ]	= "full path to the original alignment file";
    inputRedirect [ "02" ]	= "full path to the output file with extension _splits";
	ExecuteAFile ( fileToExe, inputRedirect );

