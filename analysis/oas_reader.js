const fs = require("fs");
const scriptName = "oas_reader.js"
let OUTPUT=""
let subresource_required = false;

try{
	OAS_FILE_PATH = process.argv[2];
	if ( typeof OAS_FILE_PATH === 'undefined' ){ 
		throw scriptName + ": ERROR occured while processing OAS FILE:\t require Path to file as argument." 
	}
}catch(err){
	console.log(err)
	process.exit()
}

try{
	RETURN_SUBRESOURCES = process.argv[3];
	if ( typeof RETURN_SUBRESOURCES !== 'undefined' ){ 
		if ( RETURN_SUBRESOURCES.toLowerCase() === 'true' ){
		subresource_required = true;  
		}else{
			throw scriptName + ": ERROR occured while processing OAS FILE:\t second argument is optional but should be 'true' to retrieve only subresources." 
		}
	}
}catch(err){
	console.log(err)
	process.exit()
}

const isNestedResource = (resource) => {
	let length = resource.length
	let idx = resource.indexOf("}")
	if (idx === -1){ return false;
 	}else if(resource.charAt(1) === '{') {
		resource = resource.substring( idx + 1, length)
		idx = resource.indexOf("}")
			if(idx === -1) {return false;
			}else{ return true;}
		}else{	
		return idx < length - 1;
	}
}
/*
let path="/hallo"
console.log(path +": \t" + isNestedResource(path) )

path="/hallo/hallo"
console.log(path +": \t" + isNestedResource(path) )

path="/{hallo}/hallo"
console.log(path +": \t" + isNestedResource(path) )

path="/{id}/hallo/{id}/hallo"
console.log(path +": \t" + isNestedResource(path) )

path="/{id}/hallo/{id}"
console.log(path +": \t" + isNestedResource(path) )

path="/hallo/{hallo}"
console.log(path +": \t" + isNestedResource(path) )

path="/hallo/hallo"
console.log(path +": \t" + isNestedResource(path) )

path="/hallo/hallo"
console.log(path +": \t" + isNestedResource(path) )
*/

const returnTopLevelPath = (path)=>{
	let length = path.length
	let idx_openingBrackets = path.indexOf("{")
	let idx_closingBrackets = path.indexOf("}")
	let toplevel = ''
	let sublevel = ''

	if(idx_openingBrackets < 0){return path}
	if(idx_openingBrackets > 1){ return path.substring( 0, idx_openingBrackets - 1) }
	if(idx_openingBrackets === 1){
		toplevel = path.substring( 0, idx_closingBrackets + 1 )
		sublevel = path.substring( idx_closingBrackets + 1, length )
		idx_openingBrackets = sublevel.indexOf("{")
		if (idx_openingBrackets < 0) {return toplevel.concat(sublevel)}
		if (idx_openingBrackets > 0) {
		sublevel = sublevel.substring( 0, idx_openingBrackets - 1 )
		path = toplevel.concat(sublevel)
		return path
		}
	}
}	
let contents; 
try{
	contents = fs.readFileSync(OAS_FILE_PATH, 'utf8');
}catch(err){
	console.log( scriptName+":  ERROR occured while processing OAS FILE:\t fs:couldn't read file:\t" + OAS_FILE_PATH) 
	process.exit()
}

let oas_file; 
try{
	oas_file = JSON.parse(contents)
}catch(err){
	console.log( scriptName+": ERROR occured while processing OAS FILE:\t invalid json file:\t" + OAS_FILE_PATH) 
	process.exit()
}

let paths;
try{
	paths = oas_file.paths
	if(typeof paths === 'undefined'){
		throw  scriptName+": ERROR occured while processing OAS FILE:\t file does not define paths:\t" + OAS_FILE_PATH
	}
}catch(err){
	console.log(err)
	process.exit()
}


const countAvailableMethods = (paths) =>{
	let counter=0;
	Object.keys( paths ).forEach(function( pathName ) {
  	let path = paths[pathName];
		let isNested = isNestedResource(pathName)	
		if(subresource_required === false){
			isNested = !isNested
		}
		if (isNested){
			Object.keys( path ).forEach( function( methodName ) {
				let method = path[methodName];
				if (method[ "deprecated" ] !== true ){
					counter++
				}
			});
		}
	});
	OUTPUT+="Available Operations:\t" + counter;
	//console.log("Available Operations:\t" + counter)
}

const readAvailableMethodsForToplevelResources = (paths) =>{
  let apiMapperObject = {}
	Object.keys( paths ).forEach(function( pathName ) {
		if (!isNestedResource(pathName)){
			let toplevelPath = returnTopLevelPath( pathName )
			toplevelPath = toplevelPath.replace("/", "__slash__")
			if (typeof apiMapperObject[toplevelPath] === 'undefined'){
				apiMapperObject[toplevelPath] = []
			} 
  		let path = paths[pathName];
			Object.keys( path ).forEach( function( methodName ) {
				let method = path[methodName];
				if (method[ "deprecated" ] !== true ){
					apiMapperObject[toplevelPath].push(methodName)
				}
			});
		}
	});
	return apiMapperObject
}

const readAvailableMethodsForSubResources = (paths) =>{
  let apiMapperObject = {}
	Object.keys( paths ).forEach(function( pathName ) {
		if (isNestedResource(pathName)){
			let pathNameReplaced = pathName.replace("/", "__slash__")
			pathNameReplaced = pathNameReplaced.replace("{", "__opening_brackets__")
			pathNameReplaced = pathNameReplaced.replace("}", "__closing_brackets__")
			if (typeof apiMapperObject[pathNameReplaced] === 'undefined'){
				apiMapperObject[pathNameReplaced] = []
			} 
  		let path = paths[pathName];
			Object.keys( path ).forEach( function( methodName ) {
				let method = path[methodName];
				if (method[ "deprecated" ] !== true ){
					apiMapperObject[pathNameReplaced].push(methodName)
				}
			});
		}
	});
	return apiMapperObject
}

const readAvailableMethods = (paths) => {
	if( subresource_required){
		return readAvailableMethodsForSubResources( paths ) 
	}else{
	  return readAvailableMethodsForToplevelResources( paths ) 
	} 
}

const printAvailableMethodsForToplevelRources = (apiObject) => {
	Object.keys( apiObject ).forEach( function( path ) {
		path_replaced = path.replace("__slash__", "/")
		apiObject[path].forEach( elem => {
			OUTPUT+= "\n" + elem +"\t" +path_replaced
			//console.log(elem +"\t" +path_replaced) )
		});	
	});
}

const printAvailableMethodsForSubresources = (apiObject) => {
	Object.keys( apiObject ).forEach( function( path ) {
		let path_replaced = path.replace("__slash__", "/")
		path_replaced = path_replaced.replace("__opening_brackets__", "{")
		path_replaced = path_replaced.replace("__closing_brackets__", "}")
		apiObject[path].forEach( elem => {
			OUTPUT+= "\n" + elem +"\t" +path_replaced
			//console.log(elem +"\t" +path_replaced) )
		});	
	});
}

const printAvailableMethods = (apiObject) => {
	if( subresource_required){
		printAvailableMethodsForSubresources( apiObject ) 
	}else{
		printAvailableMethodsForToplevelRources( apiObject ) 
	}
}

try{
	let apiObject= readAvailableMethods(paths)
	countAvailableMethods(paths) 
	printAvailableMethods(apiObject);
	console.log(OUTPUT)
}catch(err){
	console.log(err)
	console.log( scriptName+": ERROR occured while processing OAS FILE:\t  printing summary filed:\t" + OAS_FILE_PATH) 
	process.exit();
}



