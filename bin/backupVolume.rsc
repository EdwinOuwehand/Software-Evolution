module Volume

import IO;
import List;
import String;


/**
 * 	Tested by manually counting LOC in Strings.java in smallsql.
 *	Expected output: 85 lines in the file, 32 lines of code. 
 *	Actual output:  	84 lines in the file, 32 lines of code.
 *  This is ok! The last line is empty and doesn't get counted by Rascal.
 *  If we add something to the last line it'll count all 85 lines,
 * 	matching Eclipse's line numbering. 
 * 	The implementation correctly interprets whether the last line is code.
 */

public int linesOfCode() {
	// Directory must be root folder of an Eclipse project
	str directory = "smallsql0.21_src/src/smallsql/database";
	//str directory = "hsqldb-2.3.1/hsqldb/src/org/hsqldb"; 

	list [str] allLines 	= getAllLines(directory);
	
	println("-- Counting lines of code for .java files in <directory> --");
	println("Files total lines: <size(allLines)>");
	
	// Filter out all blank lines and one-line comments
	list [str] filteredLines = [trim(x)  | x <- allLines, 
											!isEmpty(trim(x)),	 		// Blank lines - lines with just tabs, spaces, newlines
											/^\/\*+.*\*\/$/ !:= trim(x), // /*full line comment */
											/^\/\// !:= trim(x)  		// Lines starting with // are completely commented out	
							   ];
							   	
	filteredLines = filterMultilineComments(filteredLines);
	
	println("Lines of code: <size(filteredLines)> \n\n");
	
	return size(filteredLines);
}

/**
 * 	Gets all lines of code from all the .java files in the given directory, 
 * 	given that the directory is a relative path to the root of an open Eclipse project
 */
public list [str] getAllLines(str directory) {
	list [str] files 	= [x | x <- listEntries(|project://<directory>|), /\.java$/ := x];
	return getAllLines(directory, files, []);
}

public list [str] getAllLines(str directory, list [str] files, list [str] lines) {
	if (isEmpty(files)) {
		return lines;
	}
	
	str file = head(files); 
	list [str] fileLines = readFileLines(|project://<directory>/<file>|);
	
	return getAllLines(directory, tail(files), lines + fileLines);
}


public list [str] filterMultilineComments(list [str] lines) {

	list [str] filteredLines = [];
	
	// Repeat until all lines are counted
	while(!isEmpty(lines)) {
	
		// As long as this is not an opening multiline block comment, move lines to the filteredLines list
		while(!isEmpty(lines) && false == ((/^\/\*+.*$/ := lines[0]) && (/^\/\*+.*\*\/$/ !:= lines[0])) ) {
			filteredLines = push(lines[0], filteredLines);
			lines = drop(1, lines);
		}
		
		// When we can no long do this, check: Is this the start of a multiline block comment? If so, drop lines until the end of the comment is found
		if (!isEmpty(lines) && (/^\/\*+.*$/ := lines[0]) && (/^\/\*+.*\*\/$/ !:= lines[0])) {
			lines = dropBlockComment(lines); 
		}
	}
	return filteredLines;
}

public list [str] dropBlockComment(list [str] lines) {
	str line = trim(head(lines));
	
	// If */ followed by characters (code), return including this line.
	if (/^\*\/.+/ := line) {
	 	return lines;
	}
	
	// If */ is the end of the line, return without this line.
	if (/^\*\// := line) {
		return tail(lines);
	}
	
	// End of block comment not yet reached, keep dropping
	return dropBlockComment(tail(lines));
}
