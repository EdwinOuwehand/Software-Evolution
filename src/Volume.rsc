module Volume

import IO;
import List;
import String;

/**
 *  Returns number of lines of code from all the .java files in the given directory, 
 * 	given that the directory is a relative path to the root of an open Eclipse project
 * 	"smallsql0.21_src/src/smallsql/database"
 *	"hsqldb-2.3.1/hsqldb/src/org/hsqldb"
 *		
 */
public int linesOfCode(str directory) {
	list [str] allLines 	= getAllLines(directory);
	list [str] filteredLines = filterLines(allLines);
	
	print(filteredLines);

	return size(filteredLines);
}

public list [str] filterLines(list [str] lines) {
	list [str] filteredLines = [trim(x)  | x <- lines, 
											!isEmpty(trim(x)),	 		// Blank lines - lines with just tabs, spaces, newlines
											/^\/\*+.*\*\/$/ !:= trim(x), // /*full line comment */
											/^\/\// !:= trim(x)  		// Lines starting with // are completely commented out	
							   ];
	filteredLines = filterMultilineComments(filteredLines);
	
	return filteredLines;
}

/**
 * 	Gets all lines of code from all the .java files in the given directory, 
 * 	given that the directory is a relative path to the root of an open Eclipse project
 * 	
 * 	First retrieves all filenames from directory, then overloads to recursive method 
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

/**
 *	Finds and removes multiline comments i.e. block comments and docs
 */
public list [str] filterMultilineComments(list [str] lines) {
	list [str] filteredLines = [];
	
	// Repeat until all lines are counted
	while(!isEmpty(lines)) {
	
		// As long as this is not an opening multiline block comment, move lines to the filteredLines list
		while(!isEmpty(lines) && false == ((/^\/\*+.*$/ := lines[0]) && (/^\/\*+.*\*\/$/ !:= lines[0])) ) {
			filteredLines = push(lines[0], filteredLines);
			lines = drop(1, lines);
		}
		
		// When we can no longer do this, check: Is this the start of a multiline block comment? If so, drop lines until the end of the comment is found
		if (!isEmpty(lines) && (/^\/\*+.*$/ := lines[0]) && (/^\/\*+.*\*\/$/ !:= lines[0])) {
			lines = dropBlockComment(lines); 
		}
	}
	
	return filteredLines;
}

/**
 *	Recursive method used by filterMultiLineComments to drop lines 
 *	until the end of the commment is reached, up to or including the last line 
 */
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

