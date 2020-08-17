const fs = require("fs");
const scriptName = "oas_reader.js"
let OUTPUT=""

try{
	OAS_FILE_PATH = process.argv[2];
	if ( typeof OAS_FILE_PATH === 'undefined' ){ 
		throw scriptName + ": ERROR occured while processing OAS FILE:\t require Path to file as first argument." 
	}
}catch(err){
	console.log(err)
	process.exit()
}

try{
	OPERATIONS_LIST_PATH = process.argv[3];
	if ( typeof OAS_FILE_PATH === 'undefined' ){ 
		throw scriptName + ": ERROR occured while processing OPERATION LISTINGS FILE:\t require Path to file as second argument." 
	}
}catch(err){
	console.log(err)
	process.exit()
}

try{
	PATTERNS = []
	for (i=4; i<process.argv.length;i++){
	PATTERNS.push(process.argv[i])
	}
	if (PATTERNS.length === 0){ 
		throw scriptName + ": ERROR occured while processing PATTERN:\t at least one pattern required.." 
	}
}catch(err){
	console.log(err)
	process.exit()
}

const operationsListToJson = (list) => {
	const operations=[]
	let lines =list.split(/[\r\n]+/g);
	lines.pop();
	lines.forEach(line => {
		let arrHelper = line.split(" ")
		let operation = {"method": arrHelper[0], "path":arrHelper[1]}
		operations.push(operation)
	})
	return operations
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
*/
let operationsList; 
try{
	operationsList = fs.readFileSync(OPERATIONS_LIST_PATH, 'utf8');
}catch(err){
	console.log( scriptName+":  ERROR occured while processing OAS FILE:\t fs:couldn't read file:\t" + OPERATIONS_LIST_PATH) 
	process.exit()
}

let oasFile; 
try{
	oasFile = fs.readFileSync(OAS_FILE_PATH, 'utf8');
}catch(err){
	console.log( scriptName+":  ERROR occured while processing OAS FILE:\t fs:couldn't read file:\t" + OAS_FILE_PATH) 
	process.exit()
}


let oasFileAsJson; 
try{
	oasFileAsJson = JSON.parse(oasFile)
}catch(err){
	console.log( scriptName+": ERROR occured while processing OAS FILE:\t invalid json file:\t" + OAS_FILE_PATH) 
	process.exit()
}

let paths;
try{
	paths = oasFileAsJson.paths
	if(typeof paths === 'undefined'){
		throw  scriptName+": ERROR occured while processing OAS FILE:\t file does not define paths:\t" + OAS_FILE_PATH
	}
}catch(err){
	console.log(err)
	process.exit()
}

const operationsArray = operationsListToJson(operationsList)


const checkIfIsInside = (paths, operationsArray) =>{
	operationsArray.forEach(operation =>{
		Object.keys( paths ).forEach(function( pathName ) {		
				if(pathName.startsWith(operation.path) && !isNestedResource(pathName)){
					let path=paths[pathName];
					let op=path[operation.method]
					if(typeof op !== 'undefined'){
						let operationString=JSON.stringify(op)
						let containsAll=true;


						try {
							PATTERNS.forEach( (pattern)=>{
								contains=operationString.includes(pattern)
					   		if (!contains) throw BreakException;
					 		});
						} catch (e) {
							containsAll=false;
						}
						if(containsAll){
							console.log(operation.method +"\t"+ pathName)
						}					
					}
				}	
		});
 	})
}
checkIfIsInside(paths, operationsArray)
