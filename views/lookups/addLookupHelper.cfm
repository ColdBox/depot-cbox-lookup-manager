<cfscript>
function capCase(word){ 
	if(len(word) gt 1)
		return left(uCase(word),1) & right(word,len(word)-1);
	else
		return word;
}
function singularize(word){
	if( right(word,1) eq "s" ){
		return left(word,len(word)-1);
	}
	return word;
}
</cfscript>