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
	int end = (size(lines)-1);
	
	println(lines);
	
	while(index <= end-6) {
		if(index+6 >= end) { break; }

		println("index <index>, end <end>");
		println("Looking for clone starting at <index+6>");
		
		int dupCount = 0;	
		
		// Look for the start of a clone, start at 6 places further
		for(int startClone <- [index+6 .. end]) {
		println("comparing <index>: <lines[index]> == <startClone>: <lines[startClone]>)");
	
			// Found matching line (start of clone)
			if (lines[index] == lines[startClone]) {
				println("MATCH! Find rest of the clone:");
				dupCount += 1;
				index += 1;
				
				// Search for immediately following matches
				for(int inClone <- [startClone+1 .. end+1]) {
					//println("comparing [<index>] <lines[index]> == [<inClone>] <lines[inClone]>");
				
					// Following match found
					if(lines[index] == lines[inClone]) {
						println("MATCH <lines[index]> == <lines[inClone]>");

						dupCount += 1;
						index += 1;
					
					// End of clone found, stop searching for following matches
					} else { 
						println("CONFLICT <lines[index]> != <lines[inClone]>");
						break;
					}
				}// End-if found matching start of clone
			}
			
			// If clone of at least 6 lines was found count it
			if (dupCount >= 6) {
				cloneLines += dupCount;
				dupCount = 0;
			}				 
		} 
		// End for-loop that looks for start of a clone (checks one line), start analysing next line
		index += 1;
	}
	
	// Result
	println("<cloneLines> of <n> lines are duplicated code.");
	return cloneLines;
}



/**
	for (int i <- [0 .. n-6]) {
		// Block we're looking for 		
		str checkBlock = getBlock(i);
						 
		for (int j <- [i+5 .. n]) {
			// Block to match
			str matchBlock = getBlock(j);

			
		}
	}
	
	public str getBlock(int i) {
		return trim(codelines[i]) 
			   + trim(codelines[i+1]) 
		       + trim(codeLines[i+2]) 
			   + trim(codeLines[i+3]) 
			   + trim(codeLines[i+4]) 
			   + trim(codeLines[i+5]);
	}
*/

