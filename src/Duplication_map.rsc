module Duplication_map

import Volume; 
import IO;
import List;
import String;
import DateTime;
import Map;
import ListRelation;
import Set;
import Boolean;


// Series-1/test/testfiles/duplication
// |project://smallsql0.21_src|

public int duplicatedLines(str directory) {
	println("Measuring duplication... <now()>");
	
	list [str] rawLines 	= getAllLines(|project://smallsql0.21_src|);
	list [str] lines 	= filterLines(rawLines);
	
	int n 			= size(lines);
	int cloneLines 	= 0;
	int index 		= 0; //index for keeping track of line number, as we're dropping heads when making blocks
	int threshold 	= 6;
	
	map[list[str], set[list[int]]] 	inverted 	= getInvertedBlocks(lines, threshold);
	map[list[str], set[list[int]]] duplicates 	= (block : inverted[block] | block <- inverted, size(inverted[block]) > 1);
	
	list[str] originals = dup([*d | d <- toList(domain(duplicates))]);
	list[list[int]] range = [*r | r <- toList(range(duplicates))];
	list[int] duplicateLines = dup([*d | d <- range]);

	cloneLines = size(duplicateLines) - size(originals);
		
	// Result
	println("<cloneLines> of <n> lines are duplicated code when not counting <size(originals)> originals.");
	println("<now()>");
	return cloneLines;
}

public map[list[int], list[str]] getBlocks(list[str] lines, int threshold) {
	int index = 0;
	map[list[int], list[str]] blocks = ([] : []);
	
	// Get every possible block of 6 lines with its indices
	while (size(lines) >= threshold) {
		blocks 	= blocks + ([index..index+threshold] : take(threshold, lines));
		lines 	= drop(1, lines);
		index 	+= 1;
	}
	
	return blocks;
}

/**
 *	Gets all possible blocks and stores them in a map ordered by line-content, in one go
 */ 
public map[list[str], set[list[int]]] getInvertedBlocks(list[str] lines, int threshold) {
	int index = 0;
	map[list[str], set[list[int]]] blocks = ([] : {[]});
	
	// Get every possible block of 6 lines with its indices
	while (size(lines) >= threshold) {
		// If there is already an entry for these lines
		if ((blocks[take(threshold, lines)])?) {
			blocks[take(threshold, lines)] = blocks[take(threshold, lines)] + {[index..index+threshold]};
			
		// If this is our first encounter of these lines, add new entry of lines and indexes to blocks 
		} else {
			blocks = blocks + (take(threshold, lines) : {[index..index+threshold]});
		}
		
		lines 	= drop(1, lines);
		index 	+= 1;
	}
	
	return blocks;
}

	

