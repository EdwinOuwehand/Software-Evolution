/**
 *  Module responsible for retrieving and filtering lines of Java code
 */
 module Series2::LineProcessor

import IO;
import List;
import String;
import DateTime;
import Set;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import util::FileSystem;
import util::Math;
import util::ValueUI;

private bool type2VarNames 	= false; 
private bool type2MetNames	= false;
private bool type2Literals	= false;
private bool type2Types		= false;
private bool type3 			= false;

list[Expression] vars 	= [];	
set[str] varNames	 	= {};
set[str] metNames 		= {};
set[str] literals 		= {};

/**
 * Lines containing only a bracket should not be counted as a duplicate line;
 * these brackets are moved to the previous line to retain code structure (see documentation)
 */
 public lrel[str, loc, int] moveBrackets (lrel[str, loc, int] lines) {
 	lrel[str, loc, int] result = [];
 	
 	for(int i <- index(lines)) {
 		if(lines[i][0] == "}" || lines[i][0] == "};" || lines[i][0] == "{") {
 			result[(size(result)-1)][0] += lines[i][0];
 		} else {
 			result = result + lines[i];
 		}
 	}
 	return result; 	
 }

 //Retrieve all filtered lines of code which is the sources for all metrics
 public lrel[str, loc, int] getAllFilteredLines(loc rootDir, bool t2v, bool t2m, bool t2l, bool t2t, bool t3) {
 	type2VarNames 	= t2v;
 	type2MetNames 	= t2m;
 	type2Literals 	= t2l;
 	type2Types		= t2t;
 	type3 			= t3;
 	
 	if (type2VarNames || type2MetNames || type2Literals || type2Types) {
 		getAllAstFromRootDir(rootDir);
 	}
 	
	return filterLines(getAllLines(rootDir));
}

public void getAllAstFromRootDir(loc rootDir) {
vars 		= [];	
varNames	= {};
metNames 	= {};
literals 	= {};

ast = getAllAstFromDir(rootDir);

	visit(ast) {
		case field(a, list[Expression] b): 	vars += b;
		case method(a, str b, c, d, e): 		metNames += b;
		case number(a): 						literals += a;
		case stringLiteral(a): 				literals += a;
		case characterLiteral(a): 			literals += a;
	}
	
	varNames += toSet([var.name | var <- vars]);
}

public list[Declaration] getAllAstFromDir (loc rootDir) {
	list[Declaration] asts = [];
	
	list [str] directories 	= [x | x <- listEntries(rootDir), isDirectory(rootDir + x)];
	
	while(!isEmpty(directories)) {
		asts = asts + getAllAstFromDir(rootDir + head(directories));
		directories = drop(1, directories);
	}
	
	list [str] files = [x | x <- listEntries(rootDir), /\.java$/ := x];
	for (int i <- index(files)) {
		asts = asts + createAstFromFile(rootDir+files[i], true);
	}
	return asts;
}

/**
 *	Filters out all multiline comments, single line comments and blank lines from a given list of strings
 */
public lrel[str, loc, int] filterLines(lrel[str, loc, int] lines) {

	// Filter multiline comments first, this order prevents the end of multiline comments to be deleted when: // */ 
	lrel[str, loc, int] filteredLines = filterMultilineComments(lines);

	return [<line, location, number> | <str line, loc location, int number> <- filteredLines, 
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
 *	The line content is saved along with the file loc and the original line number. 	
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
	
	if (type2VarNames || type2MetNames || type2Literals || type2Types) {
		fileLines = processCloneTypeSettings(file, fileLines);
	} 
	
	//Add locations to lines
	lrel[str, loc, int] linesLocs = [ <trim(fileLines[i]), file, i+1> | i <- index(fileLines)];
		
	return getAllLines(directory, tail(files), lines + linesLocs);
}

public list[str] processCloneTypeSettings(loc file, list[str] fileLines) {
	if(type2Types) {
		fileLines = equalizeTypes(fileLines);
	}
	
	if(type2VarNames || type2MetNames) {
		fileLines = equalizeNames(fileLines);
	}
	
	if(type2Literals) {
		fileLines = equalizeLiterals(fileLines);
	}
	
	return fileLines;
}

public list[str] equalizeTypes(list[str] fileLines) {
	list[str] names = toList(varNames + metNames);
	
	for(int i <- index(fileLines)) {
		// Split line into list of words, by space
		list[str] splitLine = separate(fileLines[i]);
		
		for(int j <- index(splitLine)) {
			if(splitLine[j] in names) {
				if(splitLine[j-1] != "=" && trim(splitLine[j-1]) != "this.") {
					splitLine[j-1] = "*typ";
				}
			}
		}
		// Turn it back into one line
		fileLines[i] = glue(splitLine);
	}
	return fileLines;
}

public list[str] equalizeNames(list[str] fileLines) {
	list[str] names = [];
	
	if (type2VarNames) {
		names += toList(varNames);
	}
	
	if (type2MetNames) {
		names += toList(metNames);
	}
	
	for(int i <- index(fileLines)) {
		// Split line into list of words, by space
		list[str] splitLine = separate(fileLines[i]);
		
		for(int j <- index(splitLine)) {
			if(splitLine[j] in names) {
				splitLine[j] = "*id";
			}
		}
		// Turn it back into one line
		fileLines[i] = glue(splitLine);
	}
	return fileLines;
}

public list[str] equalizeLiterals(list[str] fileLines) {
	
	for(int i <- index(fileLines)) {	
		// Split line into list of words, by space
		list[str] splitLine = separate(fileLines[i]);
		
		for(int j <- index(splitLine)) {
			if(splitLine[j] in literals) {
				splitLine[j] = "*val";
			}
		}
		// Turn it back into one line
		fileLines[i] = glue(splitLine);
	}	
	return fileLines;
}

public list[str] separate (str line) {
		line = replaceAll(line, ".", ". ");
		line = replaceAll(line, ",", " ,");
		line = replaceAll(line, ";", " ;");
		line = replaceAll(line, "(", " ( ");
		line = replaceAll(line, ")", " ) ");
		line = replaceAll(line, "{", " { ");
		line = replaceAll(line, "}", " } ");
		
		return split(" ", line);
}

public str glue (list[str] lines) {
		lines = [line | line <- lines, !isEmpty(line)];
		line = intercalate(" ", lines);
		return line;
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
				lines[0][0] = replaceFirst(lines[0][0], "/*", "");
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
	}

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
 