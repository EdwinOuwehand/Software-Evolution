module DuplicationAst

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


public list[start[CompilationUnit]] execute (loc project) {
	
	return [*parseIt(f) | /file(f) <- crawl(project), f.extension == "java"];
}

public start[CompilationUnit] parseIt (loc file) {
	return parse(#start[CompilationUnit], file, allowAmbiguity=true);
}



