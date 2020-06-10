const fs = require("fs");

OAS_FILE_PATH = process.argv[2];

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

const contents = fs.readFileSync(OAS_FILE_PATH, 'utf8');
const oas_file = JSON.parse(contents)
const paths = oas_file.paths

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
	console.log("Available Operations:\t" + counter)
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
		apiObject[path].forEach( elem => console.log(elem +"\t" +path_replaced) )
	});
}



let apiObject= readAvailableMethods(paths)
countAvailableMethods(paths) 
printAvailableMethods(apiObject);


