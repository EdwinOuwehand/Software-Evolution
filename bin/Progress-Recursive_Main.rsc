module Main

import IO;
import List;
import String;

public void main() {

	list [str] files = [x | x <- listEntries(|project://smallsql0.21_src/src/smallsql/database|), /\.java$/ := x];
	//println(files);

	list [str] allLines = getAllLines(files, []);
	println(size(allLines));
	
	// Filter out all blank lines and one-line comments
	list [str] filteredLines = [trim(x)  | x <- allLines, 
											!isEmpty(trim(x)),	 	// Blank lines - lines with just tabs, spaces, newlines
											/^\/\*+.*\*\/$/ !:= trim(x), // /*full line comment */
											/^\/\// !:= trim(x)  	// Lines starting with // are completely commented out	
							   ];
							   
	println(size(filteredLines));
	
	//filteredLines = filterBlockComments(filteredLines, []);
	
	println(size(filteredLines));
	
	
	//println(filteredLines);

	//list [str] lines = readFileLines(|project://smallsql0.21_src/src/smallsql/database/Column.java|);
	//println(lines);
}

public list [str] getAllLines(list [str] files, list [str] lines) {
	if (isEmpty(files)) {
		return lines;
	}
	str file = head(files); 
	list [str] fileLines = readFileLines(|project://smallsql0.21_src/src/smallsql/database/<file>|);
	
	return getAllLines(tail(files), lines + fileLines);
}


public str regBlockComment() {
	str commentOut = "/*Hello World*/";
	str validLine = "/*Hello World*/public whatever code = {";
	str opening = "/*No end of block on this line";
	
	
	bool comment = match(commentOut); //True: This IS fully a comment

	bool nonComment = match(validLine); //False: This is NOT fully commented
	
	bool open = match(opening);
	
	return "opening: <open>";
}

public bool match(str line) {
	//return /^\/\*+.*\*\/$/ := line;	//	/* block comment on whole line */
	
	
	//return /^\/\*+.*\*\/.+$/ := line; //		/* block comment*/ followed by characters
	return (/^\/\*+.*\*\/$/ !:= line) && (/^\/\*+.*$/ := line); // It's not a closing comment, but it does start with /* 
}


public list [str] filterBlockComments([], list [str] filteredLines){
	return filteredLines;
}


public list [str] filterBlockComments(list [str] lines, list [str] filteredLines) {

	str line = head(lines);
	
	// If current line is an opening block comment (starts with /*, does not end with */), drop it from the lines
	if ((/^\/\*+.*$/ := line) && (/^\/\*+.*\*\/$/ !:= line)) {
		return filterBlockComments(dropBlockComment(lines), filteredLines);
	}
	
	return filterBlockComments(tail(lines), (filteredLines + line));
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