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
		println("index <index>, end <end>");
		int dupCount = 0;
		
		if(index+6 >= end) { break; }
		
		// Look for the start of a clone, start at 6 places further
		for(int i <- [index+6 .. end]) {
	
		println("i: <i>");
			// Found matching line
			if (lines[index] == lines[i]) {
				println("MATCH: <lines[index]> and <lines[i]>");
				dupCount += 1;
				index += 1;
				
				// Search for immediately following matches
				for(int j <- [i+1 .. end+1]) {
					println("Checking follow-up match: <lines[index]> and <lines[j]>");
					// More matches found
					if(lines[index] == lines[j]) {
						println("Thats another match at <j>");
						dupCount += 1;
						index += 1;
					
					// End of clone found, stop searching for following matches
					} else { 
						println("End of the clone");
						index += 1;					
						break;
					}
				}
			} // End-if found match
			else { // No match on this line? search on next line for a match.
				println("no match here (<lines[i]>, try next line");
			}
			
			// If clone of at least 6 lines was found count it
			if (dupCount >= 6) {
				cloneLines += dupCount;
				break;
			}
				 
		} 
		// End for that looks for start of a clone, start analysing next line
		index += 1;
		
	}
	
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

