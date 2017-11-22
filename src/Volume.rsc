module Volume

import IO;
import List;
import String;
import DateTime;

/**
 *  Class responsible for retrieving and filtering lines of Java code
 */
 
 //Retrieve all filtered lines of code which will be used for all metrics
 public list[str] getAllFilteredLines(loc rootDir) {
	return filterLines(getAllLines(rootDir));
}


/**
 *	Filters out all multiline comments, single line comments and blank lines from a given list of strings
 */
public list [str] filterLines(list [str] lines) {

	// Filter multiline comments first, this order prevents the end of multiline comments to be deleted when: // */ 
	list [str] filteredLines = filterMultilineComments(lines);

	return [ trim(x) | x <- filteredLines, 
								!isEmpty(trim(x)),	 					 
								!isEntirelyBlockComment(x), 
								/^\/\// !:= trim(x) ];  // Lines starting with // are completely commented out
}

public bool isEntirelyBlockComment (str line) {
	return (/^\/\*+.*\*\/$/ := trim(line));
}

/**
 * 	Gets all lines of code from all the .java files in the given directory and nested directories, 
 * 	given that the directory is a relative path to the root of an open Eclipse project
 * 	
 * 	First step is checking for nested directories and recursively going in there first, retrieving their lines.
 * 	Then retrieve all filenames from the directory, then overloads to recursive method to get lines for each file
 */
public list [str] getAllLines(loc directory) {
	list [str] lines = [];
	list [str] directories = [x | x <- listEntries(directory), isDirectory(directory + x)];
	
	while(!isEmpty(directories)) {
		lines = lines + getAllLines(directory + head(directories));
		directories = drop(1, directories);
	}
	
	list [str] files = [x | x <- listEntries(directory), /\.java$/ := x];
	return lines + getAllLines(directory, files, []);
}

/**
  * Helper function for getAllLines.
  */
public list [str] getAllLines(loc directory, list [str] files, list [str] lines) {
	if (isEmpty(files)) {
		return lines;
	}
	
	list [str] fileLines = readFileLines(directory + head(files));
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
		while(!isEmpty(lines) && false == ((/^.*\/\*+.*.*$/ := trim(lines[0])) && (/^.*\/\*+.*\*\/.*$/ !:= trim(lines[0]))) ) {
			filteredLines = filteredLines + trim(lines[0]);
			lines = drop(1, lines);
		}

		if(!isEmpty(lines)) {
			// When we can't continue, check: 
			// Is this false alarm, is it just an occurrence of /* inside a string? If so, remove it and re-evaluate
			if(insideString(trim(lines[0]))){
				filterString = replaceFirst(lines[0], "/*", "");
				lines = drop(1, lines);
				lines = push(filterString, lines);
			} 
	
			// Is this really start of a multiline block comment? If so, drop lines until the end of the comment is found
			else if (!isEmpty(lines) && (/^.*\/\*+.*$/ := trim(lines[0])) && (/^.*\/\*+.*\*\/.*$/ !:= trim(lines[0]))) {
				lines = dropBlockComment(lines); 
			}
		}
	}
	
	return filteredLines;
}

public bool insideString (str line) {
	if(!isEmpty(line)){
		int endStr = findFirst(line, "/*");
		line = line[..endStr];		
	}
	
	// If there's an open string (noticable by odd number of ") before this /*
	if(size(findAll(line, "\"")) % 2 == 1) {
		return true;
	}
	return false;
}

/**
 *	Recursive method used by filterMultiLineComments to drop lines 
 *	until the end of the commment is reached, up to or including the last line 
 */
public list [str] dropBlockComment(list [str] lines) {
	if(isEmpty(lines)) {
		return [];
	}

	str line = trim(head(lines));
	
	// If */ followed by characters (code), return including this line.
	if (/^.*\*\/.+/ := line) {
	
	//check if immediately re-opening -> keep dropping
		if (/^.*\*\/\*/ := line) {
			dropBlockComment(tail(lines));
		} else {
			return lines;
		}
	}
	
	// If */ is the end of the line, return without this line.
	if (/^.*\*\// := line) {
		return tail(lines);
	}
	
	// End of block comment not yet reached, keep dropping
	return dropBlockComment(tail(lines));
}

