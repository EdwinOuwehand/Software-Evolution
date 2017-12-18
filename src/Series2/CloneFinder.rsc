module Series2::BlockSorter

import IO;
import Map;
import Set;
import List;
import String;
import DateTime;

import util::ValueUI;

import Series2::LineProcessor;


alias BlockOfCode = list[str];

alias File 			= loc;
alias LineNumber 	= int;
alias LineLocations 	= lrel[File, LineNumber];

// A collection of blocks of code and their locations - Per block, a set of all locations of occurrence is given
alias Blocks = map[BlockOfCode, set[LineLocations]];

public Blocks cloneClasses = ();
public int diffSize = 0;


public void testy() {
       println("Starting run at <now()>");
       //println("|project://fragment_smallsql| with threshold 6 gapsize 1");
       //lines = getAllFilteredLines(|project://fragment_smallsql|);
       //|project://smallsql0.21_src|
       //|project://Software-Evolution/test/benchmarkFiles/duplication|
       //lrel[str,loc,int] lines = getAllFilteredLines(|project://Software-Evolution/src/Series2/TinyTestfile|,true,true,true,true, false);//(|project://fragment_smallsql|, true, true, true, true, false);//(|project://smallsql0.21_src|);
       
       lines = getAllFilteredLines(|project://fragment_smallsql|, false,false,false,false,false);
       lines = moveBrackets(lines);
       
       //list[Blocks] blokjes = getAllBlocks(lines, 6);
       //cloneClasses = extractClones(blokjs);
       //iprintln(take(10,cloneClasses));
       //
       clones = (findClones(lines, 6, 1));
       //
       //println(size(clones));
               println("Done at <now()>");
       text(clones);
}
 


public Blocks findClones(lrel[str, loc, int] lines, int minThreshold, int nDiff) {	
	cloneClasses = ();
	
	if (nDiff < 0) {
		println("A NEGATIVE NUMBER OF DIFFERENCES? U MAD?");
		return ();
	}
	
	diffSize = nDiff;
	//minThreshold = 6;

	int volume 		= size(lines);

	int cloneLines 	= 0;
	


	
	// Collection of all the blocks of increasing threshold sizes. One list entry for each threshold size.
	list[Blocks] orderedBlocks 	= getAllBlocks(lines, minThreshold);	
	
	Blocks cloneClasses = extractClones(orderedBlocks);
	return cloneClasses;
}

public Blocks extractClones (list[Blocks] blocks) {
	// Reverse blocks so that the largest blocks are on front
	blocks = reverse(blocks);

	// The first block contains the largest clone classes, and does not contain overlapping blocks so can be added right away.
	cloneClasses = cloneClasses + (head(blocks));
	
	// Cut the keys up into the expected overlap keys for next blocks
	Blocks overlaps = splitBlocks(head(blocks));

	// Call recursive method for remaining blocks, pass the keys to ignore
	extractClones(tail(blocks), overlaps);
	
	return cloneClasses;
}

// Recursive method. 
// blocks: The list of blocks with decreasing threshold sizes. 
// overlaps: blocks to remove/ignore - these are overlapping blocks and already contained in cloneClasses.
public void extractClones (list[Blocks] blocksList, Blocks overlaps) {
	if(isEmpty(blocksList)) {
		return;	
	} 

	Blocks currentBlocks = head(blocksList);
	
	// Filter out overlapping blocks
	list[BlockOfCode] keys = toList(domain(overlaps));
	for (int i <- [0..size(keys)]) {
		if(currentBlocks[keys[i]]?) {
			currentBlocks[keys[i]] = currentBlocks[keys[i]] - overlaps[keys[i]];
		}
	}
	
	// Remove code blocks that do not have locations anymore 
	currentBlocks = (clone : currentBlocks[clone] | clone <- currentBlocks, size(currentBlocks[clone]) > 0);
	
	// Add remaining blocks - these should be non-overlapping only
	cloneClasses = cloneClasses + currentBlocks;
	
	// Split the remaining blocks to remove overlaps on next round, as well as the given overlaps
	Blocks nextOverlaps = ();
	nextOverlaps = nextOverlaps + (splitBlocks(currentBlocks));
	nextOverlaps = nextOverlaps + (splitBlocks(overlaps)); 
	
	// Recursion
	extractClones(tail(blocksList), nextOverlaps);
}

// Splits given blocks in all of their entire prefixes and tails, to filter out overlaps without losing t-3 clones 
public Blocks splitBlocks (Blocks blocks) {
	Blocks split = ();

	lrel [BlockOfCode, set[LineLocations]] blockList = toList(blocks);	
	int n = size(blockList);
	
	for (int i <- [0..n]) {
		// For each given block
		 tuple[BlockOfCode, set[LineLocations]] block = blockList[i];
		 
		 // Get the code fragment/map-key, and all of the associated locations
		 BlockOfCode code 				= block[0];
		 list[LineLocations] listLocs 	= toList(block[1]);
		 
		 // Split keys
		 BlockOfCode key1 = prefix(code);
		 BlockOfCode key2 = tail(code);
		 
	     set[LineLocations] val1 = {};
		 set[LineLocations] val2 = {};
		 
		 
		 // For each block of locations, add front and back to list 
		 for (int j <- [0..size(listLocs)]) {		 
		 	val1 = val1 + {prefix(listLocs[j])};
		 	val2 = val2 + {tail(listLocs[j])};
		 }
	
		split[key1] = val1;
		split[key2] = val2;
	}
	
	return split;
}



/**
 *	Create blocks of increasing threshold size until the largest clone has been found
 */
public list[Blocks] getAllBlocks (lrel[str, loc, int] lines, int threshold) {

	bool largestBlockFound 		= false;
	list[Blocks] orderedBlocks 	= [];
	
	do {
		Blocks ordBlocks		= getOrderedBlocks(lines, threshold);
		Blocks duplicates 	= (block : ordBlocks[block] | block <- ordBlocks, size(ordBlocks[block]) > 1);
		
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
public Blocks getOrderedBlocks(list[tuple[str, loc, int]] lines, int threshold) {
	Blocks ordBlocks = ();
	int index = 0;
	while (size(lines) >= threshold) {
		// Take a block, split lines from locs
		BlockOfCode blockLines 			= [bLines | <bLines, locations, lineNumbers> <- take(threshold, lines)];
		LineLocations blockLocations 	= [<locations, lineNumbers> | <lin, locations, lineNumbers> <- take(threshold, lines)];

		// If not Type-3 clone detection, simply check for exact matches 
		if (diffSize == 0) {
			// If there is already an entry for this code block, add the indices to its set of values
			if (ordBlocks[blockLines]?) {
				ordBlocks[blockLines] = ordBlocks[blockLines] + {blockLocations};
				
			// If this is our first encounter of these lines, add new entry of lines and indices to the code blocks 			
			} else {
				ordBlocks[blockLines] = {blockLocations};
			}
			
		} else {	
			// Extract the keys to be able to iterate over them
			list[list[str]] ordKeys = toList(domain(ordBlocks));
						
			// Compare current blockLines to all collected ordBlocks so far.
			for (i <- [0..size(ordKeys)]) {
				// Each time when the difference is small enough, the current block is 'categorized' here by adding its location.
				if (areSimilar(blockLines, ordKeys[i])) { 
				//println("<blockLines> - <ordKeys[i]> = <blockLines-ordKeys[i]>");
					ordBlocks[ordKeys[i]] = ordBlocks[ordKeys[i]] + {blockLocations};
				} 
			}
			
			// If this exact block doesn't have its own entry yet, add it.
			if (!ordBlocks[blockLines]?) {
				ordBlocks[blockLines] = {blockLocations};
			}
		}
		
		lines 	= drop(1, lines);
		index 	+= 1;
	}
	return ordBlocks;
}

public bool areSimilar (BlockOfCode a, BlockOfCode b) {
	int diff = 0;
	
	if(size(a) != size(b)){
		println("SIZE ERROR");
		return false;
	}
	
	for (int i <- index(a)) {
		if (a[i] != b[i]) {
			diff += 1;
		}
		if (diff > diffSize) {
			return false;
		}
	}
	return true;
}





/******** DEPRECATED - NO T-3 SUPPORT *****************
// Recursive method. 
// blocks: list of blocks of decreasing threshold size. 
// keys: keys to remove/ignore - these are overlapping blocks and already contained in cloneClasses
public void extractClones (list[Blocks] blocksList, set[BlockOfCode] overlapKeys) {
	if(isEmpty(blocksList)) {
		return;	
	} 

	Blocks currentBlocks = head(blocksList);
	
	// Filter out overlapping blocks
	currentBlocks = domainX(currentBlocks, overlapKeys);
	
	// Add remaining blocks - these should be non-overlapping only
	cloneClasses = cloneClasses + currentBlocks;
	
	// Split the keys of the remaining blocks, as well as the given overlapKeys
	set[BlockOfCode] nextKeys = {};
	nextKeys = nextKeys + (splitKeys(domain(currentBlocks)));
	nextKeys = nextKeys + (splitKeys(overlapKeys)); 
	
	// Recursion
	extractClones(tail(blocksList), nextKeys);
}

// Splits given blocks of code (which serve as keys in our map "Blocks") in [all but the last element] and [all but the first element].
public set[BlockOfCode] splitKeys (set[BlockOfCode] keys) {
	set[BlockOfCode] split = {};
	int n = size(keys);

	list[BlockOfCode] listKeys = toList(keys);

	for (int i <- index(listKeys)) {
		BlockOfCode key = listKeys[i];
		split = split + {prefix(key)};
		split = split + {tail(key)};
	}
	
	return split;
}
***********************************************/