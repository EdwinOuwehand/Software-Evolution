module Series2::Main

import Series2::BlockOrdener;
import Series2::LineProcessor;

alias BlockOfCode = list[str];

alias File 			= loc;
alias LineNumber 	= int;
alias LineLocations 	= lrel[File, LineNumber];

// A collection of blocks of code and their locations - Per block, a set of all locations of occurrence is given
alias Blocks = map[BlockOfCode, set[LineLocations]];

public Blocks run(loc rootDir, bool type2VarNames, bool type2MetNames, bool type2Literals, bool type2Types, bool type3){
	
	lines = getAllFilteredLines(rootDir, type2VarNames, type2MetNames, type2Literals, type2Types, type3);
	lines = moveBrackets(lines);	
	clones = (findClones(lines));
	
	return clones;
}
