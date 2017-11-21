module Duplication



// Series-1/test/testfiles/original


import Volume; 
import IO;
import List;
import String;

public int duplicatedLines(str directory) {
	list [str] rawLines = getAllLines(directory);
	list [str] lines = filterLines(rawLines);
	
	int n = size(lines);
	int cloneLines = 0;
	int index = 0;
	int end = (size(lines)); //not -1 because these for loops dont include the given end number
	int dupCount = 0;		
	
	//println(lines);
	
	while(index <= end-6) {
	//println("Index is <index>");
		//dupcount = 0; ???
		// Look for the start of a clone, start at 6 places further
		for(int startClone <- [index+6 .. end]) {
		//println("comparing <index>: <lines[index]> == <startClone>: <lines[startClone]>");
	
			// Found matching line (start of clone)
			if (lines[index] == lines[startClone]) {
				//println("MATCH! Find rest of the clone:");
				dupCount += 1;
				index += 1;
				//println("INDEX UP: <index>");
				
				
				// Search for immediately following matches
				for(int inClone <- [startClone+1 .. end]) {
				//println("END IS <end>");
					//println("comparing [<index>] <lines[index]> == [<inClone>] <lines[inClone]>");
				
					// Following match found
					if(lines[index] == lines[inClone]) {
						//println("MATCH <lines[index]> == <lines[inClone]>");

						dupCount += 1;
						index += 1;
						//println("INDEX UP here: <index>");
											
					// End of clone found, stop searching for following matches
					} else { 
						//println("CONFLICT <lines[index]> != <lines[inClone]>");
						break;
					}
					
				}// End-if found matching start of clone
				//println("End of the list");
				if(index >= end) {
					break;
				}
			}
			
			// If clone of at least 6 lines was found count it
			if (dupCount >= 6) {
				cloneLines += dupCount;
			} else if (dupCount > 0) {
			// restore index
				index = index - dupCount;
				//println("No valid clone, restore index to <index>");
			}				
			dupCount = 0; 
		} 
		// End for-loop that looks for start of a clone (checks one line), start analysing next line
		index += 1;
		//println("INDEX UP: <index>");
	}
	
	// Result
	println("<cloneLines> of <n> lines are duplicated code.");
	return cloneLines;
}