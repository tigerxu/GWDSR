fileToExe = HYPHY_LIB_DIRECTORY + "TemplateBatchFiles" + DIRECTORY_SEPARATOR + "GARD.bf";
 
/* a  list of file paths */

SetDialogPrompt ( "Provide a list of files to process:" );
fscanf ("input_path.txt", "Lines", _inDirectoryPaths );
 
fprintf (stdout, "[READ ", Columns (_inDirectoryPaths), " file path lines]\n");
 
/* the options passed to the GUI are encoded here */
inputRedirect = {};

inputRedirect["02"]="012345";
inputRedirect["03"]="General Discrete";
inputRedirect["04"]="3";


for ( _fileLine = 0; _fileLine < Columns ( _inDirectoryPaths ); _fileLine = _fileLine + 1 ) {
 
	inputRedirect [ "01" ]	= _inDirectoryPaths[ _fileLine ];
    inputRedirect [ "05" ]	= _inDirectoryPaths[ _fileLine ] + ".html";
	ExecuteAFile ( fileToExe, inputRedirect );
}
