module Duplication



// Series-1/test/testfiles/original


import Volume; 
import IO;
import List;
import String;

public int duplicatedLines(str directory) {
	list [str] rawLines = getAllLines(directory);
	list [str] lines = filterLines(rawLines);
	
	print(lines);

	int n = size(lines);
	int cloneLines = 0;
	
	while(!isEmpty(lines)) {
		int dupCount = 0;
		
		// Look for the start of a clone
		for(int i <- [1 .. n-1]) {
			if (i > (size(lines)-1)) {
				break;
			}
			
			if (head(lines) == lines[i]) {
				dupCount += 1;
				lines = drop(1,lines);
				
				// Search for immediately following matches
				for(int j <- [i+1 .. n-1]) {
					if (j > (size(lines)-1)) {
						break;
					}
					
					if(head(lines) == lines[j]) {
						dupCount += 1;
						lines = drop(1,lines);
						
					} else { 
						break;
					}
				}
			} 
		}		
		
		// If clone block of at least 6 lines was found count it
		if (dupCount >= 6) {
			cloneLines += dupCount;
		}
		
		lines = drop(1,lines);
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

