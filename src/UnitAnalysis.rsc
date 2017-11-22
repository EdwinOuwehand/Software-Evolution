module UnitAnalysis

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import ParseTree;
import util::Math;

import List;
import Exception;
import util::FileSystem;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import Type;

import Volume;

private list[int] ccScale 	= [50, 20, 10, 0];
private list[int] sizeScale = [60, 40, 20, 0];

private list[tuple[int, int]] analysedList;

// Source: http://www.rascal-mpl.org/#_Metrics
public list[tuple[int, int]] analyseProject(loc project) {
	lrel[int cc, int uLoc] mapCC(loc file) 
		= [<cyclomaticComplexity(m), size(filterLines(readFileLines(m@\loc)))-1> | m <- allMethods(file)];
	// Subtract 1 from uloc, for function header.
	analysedList = [*mapCC(f) | /file(f) <- crawl(project), f.extension == "java"];
	
	return analysedList;
}

public list [int] unitComplexity (int volume) {
	if(analysedList == []) throw "You must first analyse the project";

	list [int] result = [0,0,0,0];
	for (<cc, uloc> <- analysedList) {
		for(i <- index(ccScale)) {
			if(cc > ccScale[i]){
				result[i] += uloc;
				break;
			}
		}
	}
	return reverse([percent(uloc, volume) | uloc <- result]);
}

public list [int] unitSize (int volume) {
	if(analysedList == []) throw "You must first analyse the project";

	list [int] result = [0,0,0,0];
	for (<cc, uloc> <- analysedList) {
		for(i <- index(sizeScale)) {
			if(uloc > sizeScale[i]){
				result[i] += uloc;
				break;
			}
		}
	}
	return reverse([percent(uloc, volume) | uloc <- result]);
}

// Source: http://www.rascal-mpl.org/#_Metrics
public set[MethodDec] allMethods(loc file) = {m | /MethodDec m := parse(#start[CompilationUnit], file, allowAmbiguity=true)};

/**
  * & and | are still missing? 
  * Replace switch?
  * Source: http://www.rascal-mpl.org/#_Metrics
  */
public int cyclomaticComplexity(MethodDec m) {
	result = 1;
	visit (m) {
		case (Expr)`(<Expr _>)||(<Expr _>)`: result += 1;
		case (Expr)`(<Expr _>)&&(<Expr _>)`: result += 1;
		case (Stm)`do <Stm _> while (<Expr _>);`: result += 1;
	 	case (Stm)`while (<Expr _>) <Stm _>`: result += 1;
		case (Stm)`if (<Expr _>) <Stm _>`: result +=1;
		case (Stm)`if (<Expr _>) <Stm _> else <Stm _>`: result +=1;
		case (Stm)`for (<{Expr ","}* _>; <Expr? _>; <{Expr ","}*_>) <Stm _>` : result += 1;
		case (Stm)`for (<LocalVarDec _> ; <Expr? e> ; <{Expr ","}* _>) <Stm _>`: result += 1;
		case (Stm)`for (<FormalParam _> : <Expr _>) <Stm _>` : result += 1;
		case (Stm)`switch (<Expr _> ) <SwitchBlock _>`: result += 1;
		case (SwitchLabel)`case <Expr _> :` : result += 1;
		case (CatchClause)`catch (<FormalParam _>) <Block _>` : result += 1;
	}
	return result;
}
