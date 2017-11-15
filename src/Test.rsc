module Test

import Volume;

import List;
import String;

public test bool testSameLinesWhenManuallyStripped() {
	str original = "Series-1/testfiles/original";
	str filtered = "Series-1/testfiles/filtered";
	
	return linesOfCode(original) == linesOfCode(filtered);
}

public test bool testExpectedLOC() {
	int expected = size(getAllLines("Series-1/testfiles/filtered"));
	int linesOfCode = linesOfCode("Series-1/testfiles/filtered");
	
	return expected == linesOfCode;
}