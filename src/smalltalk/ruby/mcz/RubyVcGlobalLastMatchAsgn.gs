
doit
RubyVcGlobalAsgNode subclass: 'RubyVcGlobalLastMatchAsgn'
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: ''
	category: 'MagLev-AST'
	options: #()

%

set class RubyVcGlobalLastMatchAsgn
removeallmethods
removeallclassmethods

set class RubyVcGlobalLastMatchAsgn
category: '*maglev-runtime'
method:
irNode
   | asgn send | 
  (send := GsComSendNode new)   "enforce value == nil or instance of MatchData"
     rcvr: (GsComLiteralNode newObject:  MatchData) ;
     stSelector:  #_validateInstance:  ;
     appendArgument:  valueNode irEvaluatedBlockNode .
   self ir: send .
   asgn := GsComAssignmentNode _basicNew
            dest: self irLeaf  source:  send  .
   ^ self ir: asgn

%

