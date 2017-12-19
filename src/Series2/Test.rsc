module Series2::Test

import IO;

import Series2::CloneFinder;
import Series2::LineProcessor;
import Series2::Visual;

import List;

alias BlockOfCode = list[str];

alias File 			= loc;
alias LineNumber 	= int;
alias LineLocations = lrel[File, LineNumber];

public test bool allDup(){
	lines = getAllFilteredLines(|project://Software-Evolution/test/benchmarkFiles|, false, false, false, false, false);
	lines = lines + lines;
	setVolume(size(lines));
	lines = moveBrackets(lines);	
	clones = (findClones(lines, 6, 0));

	return clones != [];
}

public test bool allUnique() {
	lines = getAllFilteredLines(|project://Software-Evolution/test/benchmarkFiles|, false, false, false, false, false);
	lines = dup(lines);
	setVolume(size(lines));
	lines = moveBrackets(lines);	
	clones = (findClones(lines, 6, 0));

	println (clones); //?
	return clones == [];
}
