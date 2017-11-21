module Snippets

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

public void methodsBasedOnM3() {
	M3 myModel = createM3FromEclipseProject(|project://smallsql0.21_src/src|);
	set[loc] methods = methods(myModel);
	list[str] methodStr = [readFile(method) | method <- methods]; // Still works, ha!
}

public void totalDeclsAndStmts() {
	set[Declaration] ast = createAstsFromEclipseProject(|project://smallsql0.21_src|, true);
	
	println("Total decls:");
	println(declarations(ast));
	
	println("Total stmts:");
	println(statements(ast));
}

public int declarations(set[Declaration] ast) {
	return (0 | it + 1 | /Declaration _ := ast);
}

public int statements(set[Declaration] ast) {
	return (0 | it + 1 | /Statement _ := ast);
}
