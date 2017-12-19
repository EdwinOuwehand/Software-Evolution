module Series2::Test

import IO;

import Series2::CloneFinder;
import Series2::LineProcessor;
import Series2::Visual;
import Series2::Main;

import List;
import Map;
import Set;

alias BlockOfCode = list[str];

alias File 			= loc;
alias LineNumber 	= int;
alias LineLocations = lrel[File, LineNumber];

public test bool allDup(){
	lines = getAllFilteredLines(|project://Software-Evolution/test/benchmarkFiles/allDups|, false, false, false, false);
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
	lines = getAllFilteredLines(|project://Software-Evolution/test/benchmarkFiles/allUnique|, false, false, false, false);
	lines = moveBrackets(lines);	
	clones = (findClones(lines, 6, 0));	

	return isEmpty(clones);
}

public test bool type2() {
	clones1 = run(|project://Software-Evolution/test/benchmarkFiles/type2|, false, false, false, false, 6, 0);
	clones2 = run(|project://Software-Evolution/test/benchmarkFiles/type2|, true, true, true, true, 6, 0);
	
	return size(clones1) < size(clones2);
}

public test bool type3() {
	clones1 = run(|project://Software-Evolution/test/benchmarkFiles/type2|, false, false, false, false, 6, 0);
	clones2 = run(|project://Software-Evolution/test/benchmarkFiles/type2|, false, false, false, false, 6, 1);
	clones3 = run(|project://Software-Evolution/test/benchmarkFiles/type2|, false, false, false, false, 6, 2);
	
	return size(clones1) < size(clones2) && size(clones2) < size(clones3);
}

