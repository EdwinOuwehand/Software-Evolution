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

public list [num] unitComplexity (loc project, str src list[real] scale = [0., 10., 20., 50., 1000000.]) {
	real volume = toReal(linesOfCode(project));

	lrel[int cc, int uLoc] mapCC(loc file) 
		= [<cyclomaticComplexity(m), size(filterLines(readFileLines(m@\loc)))> | m <- allMethods(file)];
	
	list[tuple[int, int]] ccRes = [*mapCC(f) | /file(f) <- crawl(project + src)];
	
	return for (int i <- [0..4]) { 
		append round( sum([0r] + [(toReal(uloc)/volume)*100. | <cc, uloc> <- ccRes, cc >= (scale[i]+1.) && cc <= scale[i+1]]), 0.1 );
	}
}

public list [num] unitSize (loc project, str src, list[real] scale = [0., 20., 40., 60., 100000.]) {
	real volume = toReal(linesOfCode(project));
	
	list[int] mapCC(loc file) = [size(filterLines(readFileLines(m@\loc))) | m <- allMethods(file)];
	list[int] ccRes = [*mapCC(f) | /file(f) <- crawl(project + src)];
	
	return for (int i <- [0..4]) { 
		append round( sum([0r] + [(toReal(uloc)/volume)*100. | uloc <- ccRes, uloc >= (scale[i]+1.) && uloc <= scale[i+1]]), 0.1 );
	}
}

// Source: http://www.rascal-mpl.org/#_Metrics
public set[MethodDec] allMethods(loc file) = {m | /MethodDec m := parse(#start[CompilationUnit], file)};

// Source: http://www.rascal-mpl.org/#_Metrics
public int cyclomaticComplexity(MethodDec m) {
	result = 1;
	visit (m) {
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
