module Test

import Volume;

import List;
import String;
import IO;

public test bool unitCC() {
	return true;
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
