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


public Blocks findClones(lrel[str, loc, int] lines) {	
	cloneClasses = ();

	println("Start finding clones at <now()>");

	int volume 		= size(lines);
	int cloneLines 	= 0;
	int threshold 	= 6; // Minimum clone size
		
	// Collection of all the blocks of increasing threshold sizes. One list entry for each threshold size.
	list[Blocks] orderedBlocks 	= getAllBlocks(lines, threshold);	
	
	println("Ordered blocks at <now()>");
	
	Blocks cloneClasses = extractClones(orderedBlocks);
	return cloneClasses;
}

public Blocks extractClones (list[Blocks] blocks) {
	// Reverse blocks so that the largest blocks are on front
	println("Reverse blocks at <now()>");
	blocks = reverse(blocks);
	println("Done reversing at <now()>");
	// The first block contains the largest clone classes, and does not contain overlapping blocks so can be added right away.
	cloneClasses = cloneClasses + (head(blocks));
	
	// Cut the keys up into the expected overlap keys for next blocks
	println("Cutting first keys at <now()>");
	set[BlockOfCode] overlapKeys = splitKeys(domain(head(blocks)));

	println("Extracting all other clones at <now()>");
	// Call recursive method for remaining blocks, pass the keys to ignore
	extractClones(tail(blocks), overlapKeys);
	
	return cloneClasses;
}

// Recursive method. 
// blocks: list of blocks of decreasing threshold size. 
// keys: keys to remove/ignore - these are overlapping blocks and already contained in cloneClasses
public void extractClones (list[Blocks] blocksList, set[BlockOfCode] overlapKeys) {
	if(isEmpty(blocksList)) {
		println("Blocks empty at <now()>");
		return;	
	} 

	Blocks currentBlocks = head(blocksList);
	
	// Filter out overlapping blocks
	println("Filter out given keys at <now()>");
	currentBlocks = domainX(currentBlocks, overlapKeys);
	
	// Add remaining blocks - these should be non-overlapping only
	println("Adding cloneClasses at <now()>");
	cloneClasses = cloneClasses + currentBlocks;
	
	// Split the keys of the remaining blocks, as well as the given overlapKeys
	println("Splitting next keys to remove at <now()>");
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
	//println("Lets split <n> keys at <now()>");

	list[BlockOfCode] listKeys = toList(keys);

	for (int i <- index(listKeys)) {
	//println("<i>/<n>");
		BlockOfCode key = listKeys[i];
		split = split + {prefix(key)};
		split = split + {tail(key)};
	}
	println("Done splitting keys at <now()>");
	
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
	println("Largest block found at <now()> :D");
	
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
	
		/** WANTED TO DO SOMETHING LIKE THIS, BUT THERE'S NO FANCY WAY TO DO THIS :( **/		
		//tuple[list[str] lines, list[tuple[loc,int]] locs] block = 
		//	 <[blockOfLines | <blockOfLines, locations, lineNumbers> <- take(threshold, lines)], [<locations, lineNumbers> | <blockOfLines, locations, lineNumbers> <- take(threshold, lines)]>;
		
		// If there is already an entry for this code block, add the indices to its set of values
		if (ordBlocks[blockLines]?) {
			ordBlocks[blockLines] = ordBlocks[blockLines] + {blockLocations};
			
		// If this is our first encounter of these lines, add new entry of lines and indices to the code blocks 			
		} else {
			ordBlocks[blockLines] = {blockLocations};
		}
		
		lines 	= drop(1, lines);
		index 	+= 1;
	}
	return ordBlocks;
}