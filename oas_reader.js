const fs = require("fs");
const scriptName = "oas_reader.js"
let OUTPUT=""
try{
	OAS_FILE_PATH = process.argv[2];
	if ( typeof OAS_FILE_PATH === 'undefined' ){ 
		throw scriptName + ": ERROR occured while processing OAS FILE:\t require Path to file as argument." 
	}
}catch(err){
	console.log(err)
	process.exit()
}

const isNestedResource = (resource) => {
	let length = resource.length
	let idx = resource.indexOf("}")
	if(resource.charAt(1) === '{') {
		resource = resource.substring( idx + 1, length - 1 )
		idx = resource.indexOf("}")
	}	
	return idx !== -1 && idx < length - 1;
}

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
		if (!isNestedResource(pathName)){
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

const readAvailableMethods = (paths) =>{
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

const printAvailableMethods = (apiObject) => {
	Object.keys( apiObject ).forEach( function( path ) {
		path_replaced = path.replace("__slash__", "/")
		apiObject[path].forEach( elem => {
			OUTPUT+= "\n" + elem +"\t" +path_replaced
			//console.log(elem +"\t" +path_replaced) )
		});	
	});
}

try{
	let apiObject= readAvailableMethods(paths)
	countAvailableMethods(paths) 
	printAvailableMethods(apiObject);
	console.log(OUTPUT)
}catch(err){
	console.log( scriptName+": ERROR occured while processing OAS FILE:\t  printing summary filed:\t" + OAS_FILE_PATH) 
	process.exit();
}

