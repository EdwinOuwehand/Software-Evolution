module Duplication



// Series-1/test/testfiles/original


import Volume; 
import IO;
import List;
import String;
import DateTime;

public int duplicatedLines(str directory) {
	println("Measuring duplication... <now()>");
	list [str] rawLines = getAllLines(directory);
	list [str] lines = filterLines(rawLines);
	
	int n = size(lines);
	int cloneLines = 0;
	int index = 0;
	int end = (size(lines)); //not -1 because these for loops dont include the given end number
	int dupCount = 0;		
	
	//println(lines);
	
	while(size(lines) > 6) {
	//println("<size(lines)> lines to go");
	//println("Index is <index>");
		//dupcount = 0; ???
		index = 0;
		// Look for the start of a clone, start at 6 places further
		for(int startClone <- [6 .. size(lines)]) {
		//println("comparing <index>: <lines[index]> == <startClone>: <lines[startClone]>");
			if(startClone >= size(lines)) { // Size is dynamically decreasing, so need to check and break
				break;
			}
			
			// Just ignore and skip accolades, we really don't want these triggering the start of the clone o.o;;
			if(lines[0] == "{" || lines[0] == "}" || lines[0] == "};") {
				lines = drop(1, lines);
				break;
			}
			
			// Found matching line (start of clone)
			if (lines[index] == lines[startClone]) {
				//println("START CLONE");
				dupCount += 1;
				index += 1;
				//println("INDEX UP: <index>");
				
				
				// Search for immediately following matches
				for(int inClone <- [startClone+1 .. size(lines)]) {
				if(inClone >= size(lines)) {
					break;
				}
					//println("comparing [<index>] <lines[index]> == [<inClone>] <lines[inClone]>");
					//println("SEARCH <inClone>");
					// Following match found
					if(lines[index] == lines[inClone]) {
						//println("MATCH IN CLONE");

						dupCount += 1;
						index += 1;
						//println("INDEX UP: <index> (in clone)");
											
					} else { 
						// End of clone found, stop searching for following matches
						//println("END CLONE");
						//println("CONFLICT <lines[index]> != <lines[inClone]>");
						break;
					}
					
				}// End-if found matching start of clone
				//println("End of the list");
				if(index >= size(lines)) {
					break;
				}
			}
			
			// If clone of at least 6 lines was found count it
			if (dupCount >= 6) {
				cloneLines += dupCount;
				lines = drop(index, lines);      
				//println("DROPPED <index> LINES");              
			} else if (dupCount > 0) {
			// restore index
			//println("Thought <lines[index]>   &     <lines[index-dupCount]> were cloned lines");
				index = index - dupCount;
				//println("RESTORED INDEX TO <index>");
				//println("No valid clone, restore index to <index>");
			}
			//println("RESET DUPCOUNT");				
			dupCount = 0; 
		} // End for-loop that looks for start of a clone (checks one line), start analysing next line
		//println("DROP HEAD");
		lines = drop(1, lines);
		//println("INDEX UP: <index>");
	}
	
	// Result
	println("<cloneLines> of <n> lines are duplicated code.");
	println("<now()>");
	return cloneLines;
}