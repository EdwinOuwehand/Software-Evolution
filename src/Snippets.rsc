module Snippets

import IO;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;
import util::FileSystem;
import util::Math;

import ParseTree;
import Exception;
import List;
import Type;

public lrel[str, loc] methodsBasedOnM3() {
	M3 myModel = createM3FromEclipseProject(|project://smallsql0.21_src/src|);
	set[loc] methods = methods(myModel);
	return [<readFile(method), method> | method <- methods]; // Still works, ha!
	
	//return methodStr;
}

public void totalDeclsAndStmts() {
	set[Declaration] ast = createAstsFromEclipseProject(|project://smallsql0.21_src|, true);
	
	println("Total decls:");
	println(declarations(ast));
	
	println("Total stmts:");
	println(statements(ast));
}

public void averageUnitSize(list[tuple[int, int]] ccRes, real volume){
	println( toReal(sum([uloc | <cc, uloc> <- ccRes])) / toReal(size(ccRes)) );
}

public int declarations(set[Declaration] ast) {
	return (0 | it + 1 | /Declaration _ := ast);
}

public int statements(set[Declaration] ast) {
	return (0 | it + 1 | /Statement _ := ast);
}
