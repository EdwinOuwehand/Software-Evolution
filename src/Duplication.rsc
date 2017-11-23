module Duplication

import IO;
import Map;
import Set;
import List;
import String;
import DateTime;

public int duplicatedLines(list[str] lines) {	
	int volume 		= size(lines);
	int cloneLines 	= 0;
	int threshold 	= 6;
	
	lines = removeBrackets(lines);
	
	map[list[str], set[list[int]]] 	inverted 	= getInvertedBlocks(lines, threshold);
	map[list[str], set[list[int]]] duplicates 	= (block : inverted[block] | block <- inverted, size(inverted[block]) > 1);
	
	list[str] originals 			= dup([*d | d <- toList(domain(duplicates))]);
	list[list[int]] range		= 	  [*r | r <- toList(range(duplicates))];
	list[int] duplicateLines 	= dup([*d | d <- range]);

	cloneLines = size(duplicateLines) - size(originals);
	
	println("<cloneLines> out of <volume> lines are duplicated code. Removed bracket lines before cheking, and did not count <size(originals)> original occurences.");
	return cloneLines;
}

/**
 *	Gets all possible consecutive code blocks of given threshold size, and stores them in a map ordered by line-content, in one go
 */ 
public map[list[str], set[list[int]]] getInvertedBlocks(list[str] lines, int threshold) {
	map[list[str], set[list[int]]] blocks = ();
	
	int index = 0;
	while (size(lines) >= threshold) {
		// If there is already an entry for this code block, add the indices to its set of values
		if (blocks[take(threshold, lines)]?) {
			blocks[take(threshold, lines)] = blocks[take(threshold, lines)] + {[index..index+threshold]};
			
		// If this is our first encounter of these lines, add new entry of lines and indices to the code blocks 			
		} else {
			blocks[take(threshold, lines)] = {[index..index+threshold]};
		}
		
		lines 	= drop(1, lines);
		index 	+= 1;
	}
	return blocks;
}

/**
 * 	Removes brackets from the source lines
 */
public list[str] removeBrackets(list [str] lines) {
	return [ l | l <- lines, l != "{", l != "}", l != "};"]; 
}