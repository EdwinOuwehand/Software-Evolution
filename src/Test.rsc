module Test

import Volume;

import List;
import String;
import IO;

public test bool unitCC() {
	return true;
}

public test bool testSameLinesWhenManuallyStripped() {
	str original = "Software-Evolution/test/testfiles/original";
	str filtered = "Software-Evolution/test/testfiles/filtered";
	
	return linesOfCode(original) == linesOfCode(filtered);
}

public test bool testExpectedLOC() {
	int expected = size(getAllLines("Software-Evolution/test/testfiles/filtered"));
	int linesOfCode = linesOfCode("Software-Evolution/test/testfiles/filtered");
	
	return expected == linesOfCode;
}

public test bool testTokenizerFileExpectedLOC() {
	int expected = size(getAllLines("Software-Evolution/test/testfiles/debugtokenizer/filtered"));
	int linesOfCode = linesOfCode("Software-Evolution/test/testfiles/debugtokenizer/original");
	
	println("<expected> == <linesOfCode> ?");
	return expected == linesOfCode;
}

public test bool testTokenizerFileSameLinesWhenManuallyStripped() {
	str original = "Software-Evolution/test/testfiles/debugtokenizer/original";
	str filtered = "Software-Evolution/test/testfiles/debugtokenizer/filtered";
	
	int orig = linesOfCode(original);
	int filt = linesOfCode(filtered);
	
	println("<orig> == <filt> ?");

	return orig == filt;
}
