module Series2::BlockOrdener

import IO;
import Map;
import Set;
import List;
import String;
import DateTime;

public int findClones(lrel[str, loc, int] lines) {	
	int volume 		= size(lines);
	int cloneLines 	= 0;
	int threshold 	= 6; // Minimum clone size
	
	map[list[str], set[lrel[loc,int]]] cloneClasses 			= (); 
	list[map[list[str], set[lrel[loc,int]]]] orderedBlocks 	= getAllBlocks(lines, threshold);	// Collection of all the blocks, one list entry for each threshold size.
	
	// TODO: 
	// 		- Start on the bottom of orderedBlocks i.e. the largest blocks
	//		- Note: These are guaranteed duplicates, unique blocks have already been filtered out :)
	//		- This entry will only contain one or multiple non-overlapping blocks. 
	//				- Add these blocks to the cloneClasses map
	//				- Make a list of the keys of the entries that must be deleted in the next block (1 step smaller) e.g. for "abcdefg" you will want to delete "abcdef" and "bcdefg" in the next step
	//				- Return this list of overlap-keys
	//		- Repeat for each entry:
	//				- Delete given overlap-keys
	// 				- Remaining blocks should be non-overlapping blocks 
	//				- Add remaining blocks to cloneClasses
	//				- Cut up deleted overlap-keys and remaining block keys for next run 
	
	
	return cloneLines;
}

/**
 *	Create blocks of increasing threshold size until the largest clone has been found
 */
public list[map[list[str], set[lrel[loc,int]]]] getAllBlocks (lrel[str, loc, int] lines, int threshold) {
	bool largestBlockFound = false;
	list[map[list[str], set[lrel[loc,int]]]] orderedBlocks = [];
	
	do {
		map[list[str], set[lrel[loc,int]]] ordBlocks		= getOrderedBlocks(lines, threshold);
		map[list[str], set[lrel[loc,int]]] duplicates 	= (block : ordBlocks[block] | block <- ordBlocks, size(ordBlocks[block]) > 1);
		
		orderedBlocks = orderedBlocks + duplicates;
		threshold += 1;
		
		// No overlapping blocks means biggest clone block found
		if(size(duplicates) <= 1) {
			largestBlockFound = true;
		}		
	} while (!largestBlockFound);
	
	return orderedBlocks;
}

/**
 *	Gets all consecutive code blocks of given threshold size, and stores them in a map ordered by line-content
 *	Works for type 1 by default, 
 * 	- For type 2 if identifiers etc. are made uniform first,
 *	- For type 3 if ordering of blocks takes note of gaps (TODO)
 */ 
public map[list[str], set[lrel[loc,int]]] getOrderedBlocks(list[tuple[str, loc, int]] lines, int threshold) {
	map[list[str], set[lrel[loc,int]]] ordBlocks = ();
	int index = 0;
	
	while (size(lines) >= threshold) {
		// Take a block, split lines from locs
		list [str] blockLines 			= [bLines | <bLines, locations, lineNumbers> <- take(threshold, lines)];
		list [tuple[loc,int]] blockLocs 	= [<locations, lineNumbers> | <lin, locations, lineNumbers> <- take(threshold, lines)];
	
		/** WANTED TO DO SOMETHING LIKE THIS, BUT THERE'S NO FANCY WAY TO DO THIS :( **/		
		//tuple[list[str] lines, list[tuple[loc,int]] locs] block = 
		//	 <[blockOfLines | <blockOfLines, locations, lineNumbers> <- take(threshold, lines)], [<locations, lineNumbers> | <blockOfLines, locations, lineNumbers> <- take(threshold, lines)]>;
		
		// If there is already an entry for this code block, add the indices to its set of values
		if (ordBlocks[blockLines]?) {
			ordBlocks[blockLines] = ordBlocks[blockLines] + {blockLocs};
			
		// If this is our first encounter of these lines, add new entry of lines and indices to the code blocks 			
		} else {
			ordBlocks[blockLines] = {blockLocs};
		}
		
		lines 	= drop(1, lines);
		index 	+= 1;
	}
	return ordBlocks;
}