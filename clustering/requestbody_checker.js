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

//const operationsArray = operationsListToJson(operationsList)


const checkIfIsInside = (paths) =>{
		Object.keys( paths ).forEach(function( pathName ) {		
				if( !isNestedResource(pathName) ){
						let path=paths[pathName];
						Object.keys(path).forEach( function ( operationName ) {
								if (operationName.toLowerCase() === "post"){
								  operation=path[operationName]
									if (!('requestBody' in operation)) {
										console.log("####################################################################")
   								  console.log(OAS_FILE_PATH) 
										console.log(pathName)
								    console.log(operation)
								    console.log("\n\n\n")
									}
								}
						})
				}					
		})
}
checkIfIsInside(paths)
