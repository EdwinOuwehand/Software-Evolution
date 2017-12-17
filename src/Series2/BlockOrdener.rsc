module Series2::BlockOrdener

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
       //lines = getAllFilteredLines(|project://fragment_smallsql|);
       //|project://smallsql0.21_src|
       //|project://Software-Evolution/test/benchmarkFiles/duplication|
       //lrel[str,loc,int] lines = getAllFilteredLines(|project://Software-Evolution/src/Series2/TinyTestfile|,true,true,true,true, false);//(|project://fragment_smallsql|, true, true, true, true, false);//(|project://smallsql0.21_src|);
       
       lines = getAllFilteredLines(|project://Software-Evolution/test/benchmarkFiles/duplication|, false,false,false,false,false);
       lines = moveBrackets(lines);
       
       //list[Blocks] blokjes = getAllBlocks(lines, 6);
       //cloneClasses = extractClones(blokjs);
       //iprintln(take(10,cloneClasses));
       //
       clones = (findClones(lines, 6, 1));
       //
       //println(size(clones));
               println("Done at <now()>");
       
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
	set[BlockOfCode] overlapKeys = splitKeys(domain(head(blocks)));

	// Call recursive method for remaining blocks, pass the keys to ignore
	extractClones(tail(blocks), overlapKeys);
	
	return cloneClasses;
}

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
				if (size(blockLines - ordKeys[i]) <= diffSize) {
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