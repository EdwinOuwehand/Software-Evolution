/**
 *  Module responsible for retrieving and filtering lines of Java code
 */
 module Series2::LineProcessor

import IO;
import List;
import String;
import DateTime;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import util::FileSystem;
import util::Math;
//
//import Node;
//
import util::ValueUI;
//
//import Set;
//
//import ParseTree;
//import Exception;
//import List;
//import Type;


public bool type2VarNames 	= false; 
public bool type2MetNames	= false;
public bool type2Literals	= false;
public bool type2Types		= false;
public bool type3 			= false;

public void testy() {

	//str hoi = "   ha ll o    ";
	//println(hoi);
	//println(trim(hoi));
	lrel[str,loc,int] lines = getAllFilteredLines(|project://Software-Evolution/src/Series2/TinyTestfile|,true,true,true,true, false);//(|project://fragment_smallsql|, true, true, true, true, false);//(|project://smallsql0.21_src|);
	list[str] rlinesList = [rlines | <rlines, fl, ln> <- lines];
	print(rlinesList);
	//
	lines = moveBrackets(lines);
	text(lines);
}

// Lines containing only a bracket should not be counted as a duplicate line; these brackets are moved to the previous line to retain code structure (see documentation)
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
	
	if (type2VarNames || type2MetNames || type2Literals || type2Types || type3) {
		fileLines = processCloneTypeSettings(file, fileLines);
	} 
	
	//Add locations to lines
	lrel[str, loc, int] linesLocs = [ <trim(fileLines[i]), file, i+1> | i <- index(fileLines)];
		
	return getAllLines(directory, tail(files), lines + linesLocs);
}

public list[str] processCloneTypeSettings(loc file, list[str] fileLines) {
	Declaration ast = createAstFromFile(file, true);
	
	list[Expression] vars 	= [];	
	list[str] varNames	 	= [];
	list[str] metNames 		= [];
	list[str] literals 		= [];
		
	visit(ast) {
		case field(a, list[Expression] b): 	vars += b;
		case method(a, str b, c, d, e): 		metNames += b;
		case number(a): 						literals += a;
		case stringLiteral(a): 				literals += a;
		case characterLiteral(a): 			literals += a;
	}
	
	varNames = [var.name | var <- vars];
	
	if(type2Types) {
		fileLines = equalizeTypes(fileLines, varNames, metNames);
	}
	
	if(type2VarNames || type2MetNames) {
		fileLines = equalizeNames(fileLines, varNames, metNames);
	}
	
	if(type2Literals) {
		fileLines = equalizeLiterals(fileLines, literals);
	}
	
	return fileLines;
}

public list[str] equalizeTypes(list[str] fileLines, list[str] varNames, list[str] metNames) {
	list[str] names = varNames + metNames;
	
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

public list[str] equalizeNames(list[str] fileLines, list[str] varNames, list[str] metNames) {
	list[str] names = [];
	
	if (type2VarNames) {
		names += varNames;
	}
	
	if (type2MetNames) {
		names += metNames;
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

public list[str] equalizeLiterals(list[str] fileLines, list[str] literals) {
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
	
	//	Not necessary, all lines get same treatment anyway, some extra spaces in between don't matter.
	
	//	line = replaceAll(line, ". ", ".");
	//	line = replaceAll(line, " ,", ",");
	//	line = replaceAll(line, " ;", ";");
	//	line = replaceAll(line, " ( ", "(");
	//	line = replaceAll(line, " )", ")");
	//	line = replaceAll(line, " {", "{");
	//	line = replaceAll(line, " } ", "}");
	
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