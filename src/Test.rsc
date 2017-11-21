module Test

import Volume;
import UnitAnalysis;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import ParseTree;
import util::Math;

import Exception;
import util::FileSystem;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import Type;

import List;
import String;
import IO;
import util::Math;

// 129 lines 60 low, 37 moderate, 0 high, 0 very high, 32 non unit lines
public test bool unitCCLines() { 
	project = |project://Software-Evolution/test/benchmarkFiles/filtered|;
	list[loc] linesPerUnit = [*[m@\loc | m <- allMethods(f)] | /file(f) <- crawl(project)];
	
	int totalUnitLines = size([*readFileLines(e) | e <- linesPerUnit]);
	real relativeUnitLines = 
		round(toReal(totalUnitLines)/toReal(linesOfCode(project))*100., 0.1);
	
	return relativeUnitLines == sum(unitComplexity(project, ""));
}

public test bool unitCCExpectedByManualCount () {
	return unitComplexity(|project://Software-Evolution/test/benchmarkFiles/filtered|, "") == [46.5,28.7,0.0,0.0];
}

public test bool unitSizeLines() {
		project = |project://Software-Evolution/test/benchmarkFiles/filtered|;
	list[loc] linesPerUnit = [*[m@\loc | m <- allMethods(f)] | /file(f) <- crawl(project)];
	
	int totalUnitLines = size([*readFileLines(e) | e <- linesPerUnit]);
	real relativeUnitLines = 
		round(toReal(totalUnitLines)/toReal(linesOfCode(project))*100., 0.1);
		
	return relativeUnitLines == sum(unitSize(project, ""));
}

public test bool knownVolume () {
	return linesOfCode(|project://Software-Evolution/test/benchmarkFiles/original|) == 129;
}

public test bool testSameLinesWhenManuallyStripped() {
	loc original = |project://Software-Evolution/test/benchmarkFiles/original|;
	loc filtered = |project://Software-Evolution/test/benchmarkFiles/filtered|;
	
	return linesOfCode(original) == linesOfCode(filtered);
}

public test bool testExpectedLOC() {
	int expected = size(getAllLines(|project://Software-Evolution/test/benchmarkFiles/filtered|));
	int linesOfCode = linesOfCode(|project://Software-Evolution/test/benchmarkFiles/filtered|);
	
	return expected == linesOfCode;
}

public test bool testTokenizerFileExpectedLOC() {
	int expected = size(getAllLines(|project://Software-Evolution/test/benchmarkFiles/filtered|));
	int linesOfCode = linesOfCode(|project://Software-Evolution/test/benchmarkFiles/original|);
	
	return expected == linesOfCode;
}

public test bool testTokenizerFileSameLinesWhenManuallyStripped() {
	loc original = |project://Software-Evolution/test/benchmarkFiles/original|;
	loc filtered = |project://Software-Evolution/test/benchmarkFiles/filtered|;
	
	int orig = linesOfCode(original);
	int filt = linesOfCode(filtered);

	return orig == filt;
}
