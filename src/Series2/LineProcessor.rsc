/**
 *  Module responsible for retrieving and filtering lines of Java code
 */
 module Series2::LineProcessor

import IO;
import List;
import String;
import DateTime;

 //Retrieve all filtered lines of code which is the sources for all metrics
 public lrel[str, loc, int] getAllFilteredLines(loc rootDir) {
	return filterLines(getAllLines(rootDir));
}

/**
 *	Filters out all multiline comments, single line comments and blank lines from a given list of strings
 */
public lrel[str, loc, int] filterLines(lrel[str, loc, int] lines) {

	// Filter multiline comments first, this order prevents the end of multiline comments to be deleted when: // */ 
	lrel[str, loc, int] filteredLines = filterMultilineComments(lines);

	return [<line, location, number> | <line, location, number> <- filteredLines, 
										!isEmpty(line),	 				// 		Blank lines	 
										!isEntirelyBlockComment(line), 	//		/* Block comment style on one line*/
										/^\/\// !:= line ]; 				// 		Lines starting with // are completely commented out
}

public bool isEntirelyBlockComment (str line) {
	return (/^\/\*+.*\*\/$/ := trim(line));
}

/**
 * 	Gets all lines of code from all the .java files in the given directory and nested directories, 
 * 	given that the directory is a relative path to the root of an imported Eclipse project.
 * 	
 * 	First step is checking for nested directories and recursively going in there first, retrieving their lines.
 * 	Then retrieve all filenames from the directory, then overloads to recursive method to get lines for each file.
 */
public lrel[str, loc, int] getAllLines(loc directory) {
	lrel[str, loc, int] lines = [];
	list [str] directories 	= [x | x <- listEntries(directory), isDirectory(directory + x)];
	
	while(!isEmpty(directories)) {
		lines = lines + getAllLines(directory + head(directories));
		directories = drop(1, directories);
	}
	
	list [str] files = [x | x <- listEntries(directory), /\.java$/ := x];
	return lines + getAllLines(directory, files, []);
}

/**
  * Overloaded recusive worker for getAllLines.
  */
public lrel[str, loc, int] getAllLines(loc directory, list [str] files, lrel[str, loc, int] lines) {
	if (isEmpty(files)) {
		return lines;
	}
	
	loc file = directory + head(files);
	list [str] fileLines = readFileLines(file);
	
	//Add locations to lines
	lrel[str, loc, int] linesLocs = [ <trim(fileLines[i]), file, i+1> | i <- index(fileLines)];
		
	return getAllLines(directory, tail(files), lines + linesLocs);
}

/**
 *	Finds and removes multiline comments i.e. block comments and docs
 */
public lrel[str, loc, int] filterMultilineComments(lrel[str, loc, int] lines) {
	lrel[str, loc, int]  filteredLines = [];
	
	// Repeat until all lines are counted
	while(!isEmpty(lines)) {
	
		// As long as this is not an opening multiline block comment, move lines to the filteredLines list
		while(!isEmpty(lines) && !startOfMultilineBlockComment(lines[0][0])) {
			filteredLines = filteredLines + lines[0];
			lines = drop(1, lines);
		}

		if(!isEmpty(lines)) {
			// When we can't continue, check: 
			// Is this false alarm, is it just an occurrence of /* inside a string? If so, remove it and re-evaluate
			if(insideString(lines[0][0])){
				//filterString = replaceFirst(lines[0][0], "/*", "");
				lines[0][0] = replaceFirst(lines[0][0], "/*", "");
				//lines = drop(1, lines);
				//lines = push(filterString, lines);
			} 
	
			// Is this really start of a multiline block comment? If so, drop lines until the end of the comment is found
			else if (!isEmpty(lines) && startOfMultilineBlockComment(lines[0][0])) {
				lines = dropBlockComment(lines); 
			}
		}
	}
	return filteredLines;
}

public bool startOfMultilineBlockComment(str line) {
	return (/^.*\/\*+.*$/ := line) && (/^.*\/\*+.*\*\/.*$/ !:= line);
}

public bool insideString (str line) {
	if(!isEmpty(line)) {
		int endStr 	= findFirst(line, "/*");
		line 		= line[..endStr];		
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
public lrel[str, loc, int] dropBlockComment(lrel[str, loc, int] lines) {
	if(isEmpty(lines)) {
		return [];
	}//todo???

	str line = lines[0][0];
	
	// If */ followed by characters (code), return including this line.
	if (/^.*\*\/.+/ := line) {
	
	//check if immediately re-opening -> keep dropping. Otherwise */ /* will break things and start including comments
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

 public int linesOfCode(loc rootDir){
	return size(filterLines(getAllLines(rootDir)));
 }