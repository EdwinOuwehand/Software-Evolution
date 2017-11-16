module Test

import Volume;

import List;
import String;
import IO;

public test bool testSameLinesWhenManuallyStripped() {
	str original = "Series-1/test/testfiles/original";
	str filtered = "Series-1/test/testfiles/filtered";
	
	return linesOfCode(original) == linesOfCode(filtered);
}

public test bool testExpectedLOC() {
	int expected = size(getAllLines("Series-1/test/testfiles/filtered"));
	int linesOfCode = linesOfCode("Series-1/test/testfiles/filtered");
	
	return expected == linesOfCode;
}

public test bool testTokenizerFileExpectedLOC() {
	int expected = size(getAllLines("Series-1/test/testfiles/debugtokenizer/filtered"));
	int linesOfCode = linesOfCode("Series-1/test/testfiles/debugtokenizer/original");
	
	println("<expected> == <linesOfCode> ?");
	return expected == linesOfCode;
}

public test bool testTokenizerFileSameLinesWhenManuallyStripped() {
	str original = "Series-1/test/testfiles/debugtokenizer/original";
	str filtered = "Series-1/test/testfiles/debugtokenizer/filtered";
	
	int orig = linesOfCode(original);
	int filt = linesOfCode(filtered);
	
	println("<orig> == <filt> ?");

	return orig == filt;
}
