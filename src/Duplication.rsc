module Duplication

import Volume; 
import IO;
import List;
import String;
import DateTime;
import Map;
import Set;
import ValueIO;



// Series-1/test/testfiles/duplication
// |project://smallsql0.21_src|


public int duplicatedLines(list[str] lines) {	
	list [str] relevantLines = removeNonRelevant(lines);
	
	int n 			= size(lines);
	int cloneLines 	= 0;
	int index 		= 0; //index for keeping track of line number, as we're dropping heads when making blocks
	int threshold 	= 6;
	
	map[list[str], set[list[int]]] 	inverted 	= getInvertedBlocks(relevantLines, threshold);
	map[list[str], set[list[int]]] duplicates 	= (block : inverted[block] | block <- inverted, size(inverted[block]) > 1);
	//map[list[str], set[list[int]]] noBrackets 	= removeBracketBlocks(duplicates); // Removes brackets after the check, see documentation
	//duplicates = noBrackets;
	
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
	map[list[int], list[str]] blocks = ();
	
	// Get every possible block of 6 lines with its indices
	while (size(lines) >= threshold) {
		//blocks 	= blocks + ([index..index+threshold] : take(threshold, lines));
		blocks[[index..index+threshold]] = take(threshold, lines);
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

// Removes characters from the source before the check
public list[str] removeNonRelevant(list [str] lines){
	return [ l | l <- lines, l != "{", l != "}", l != "};"];  //, /^import/ !:= l
}

// Removes blocks with brackets to ignore after the check 
//public map[list[str], set[list[int]]] removeBracketBlocks(map[list[str], set[list[int]]] blocks) {
//	// Find all keys (blocks) starting with { or ending with } or };
//	set[list[str]] brackets = {block | block <- domain(blocks), head(block) != "{", last(block) != "}", last(block) != "};"
//	};
//	
//	return  (block : blocks[block] | block <- blocks, block notin brackets);
//}



//YAY, BUGS! davy.landman@cwi.nl

public map[list[int], list[str]] main(){
	list [str] rawLines 			= getAllLines(|project://Software-Evolution/test/benchmarkFiles/duplication|);
	list [str] lines 			= filterLines(rawLines);
	
	blocks = getBlocks(lines, 3);
	writeBinaryValueFile(|file:///tmp/test.bin|, blocks);
	iprintln(invert(blocks));
	
	blocks2 = readBinaryValueFile(#map[list[int], list[str]],|file:///tmp/test.bin|);
	
	println("<blocks  == blocks2>");
	iprintln(invert(blocks2));
	println("<invert(blocks)  == invert(blocks2)>");
	return blocks;
}
