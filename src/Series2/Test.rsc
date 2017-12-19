module Series2::Test

import IO;

import Series2::CloneFinder;
import Series2::LineProcessor;
import Series2::Visual;

import List;
import Map;
import Set;

alias BlockOfCode = list[str];

alias File 			= loc;
alias LineNumber 	= int;
alias LineLocations = lrel[File, LineNumber];

public test bool allDup(){
	lines = getAllFilteredLines(|project://Software-Evolution/test/benchmarkFiles/allDups|, false, false, false, false, false);
	lines = moveBrackets(lines);	
	n_lines = size(lines);
	clones = (findClones(lines, 6, 0));
	
	set[lrel[loc,int]] dupLines = {};
	
	cloneClassesList = toList(clones);
	for(int i <- index(cloneClassesList)) {
		dupLines = dupLines + cloneClassesList[i][1];
	}
	n_dups = getNumberDupLines(dupLines);		

	return n_dups == n_lines;
}

public test bool allUnique() {
	lines = getAllFilteredLines(|project://Software-Evolution/test/benchmarkFiles/allDups|, false, false, false, false, false);
	lines = dup(lines);
	lines = moveBrackets(lines);	
	clones = (findClones(lines, 6, 0));	

	return clones == [];
}
//
//public test bool type2() {
//	type2VarNames 	= true;
// 	type2MetNames 	= true;
// 	type2Literals 	= true;
// 	type2Types		= true;
// 	
//	println (getAllLines(|project://Software-Evolution/test/benchmarkFiles/type2|));
//
//}

