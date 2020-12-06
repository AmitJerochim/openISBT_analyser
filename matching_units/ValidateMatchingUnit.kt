package matching.units

import com.google.gson.GsonBuilder
import de.tuberlin.mcc.openapispecification.OpenAPISPecifcation
import de.tuberlin.mcc.openapispecification.*
import de.tuberlin.mcc.openapispecification.PathItemObject
import de.tuberlin.mcc.patternconfiguration.AbstractOperation
import io.ktor.http.ContentType
import mapping.PatternOperation
import matching.MatchingUnit
import matching.MatchingUtil
import org.slf4j.LoggerFactory
import patternconfiguration.AbstractPatternOperation
import matching.ReferenceResolver
class ValidateMatchingUnit : MatchingUnit{

    val log = LoggerFactory.getLogger("ValidateMatchingUnit");

    override fun getSupportedOperation(): String {
        return AbstractPatternOperation.VALIDATE.name;
    }

    override fun match(pathItemObject: PathItemObject, abstractOperation: AbstractOperation, spec: OpenAPISPecifcation, path: String): PatternOperation? {
        if (pathItemObject.get != null) {
						//log.info(pathItemObject.get.toString())
						//var path1:PathItemObject = ReferenceResolver().resolveReference(pathItemObject	
            //get could support READ or SCAN
            //If no array is returned, READ is supported
						var isAuth=false
            for (response in pathItemObject.get.responses.responses.values) {
								var res:ResponseObject
								if(response.`$ref` != null){
										res = ReferenceResolver().resolveReference(response.`$ref`!!, spec) as ResponseObject			
										//res = response
								}else{
										res = response
								}
                if (res.content != null) {
										//response.content includes the mediaType, a mediaType object(Schema)
										//log.info(response.content.toString())
										//content is a MediaType object==schema
                    for (content in res.content.values) {
                        if (content.schema != null) {
														var schema:SchemaObject
														if(content.schema.`$ref` != null){
																schema = ReferenceResolver().resolveReference(content.schema.`$ref`!!, spec) as SchemaObject
														}else{
													      schema = content.schema
														}	
                            if (schema.type == "object") {
                            		if (schema.properties != null){
																		var props = schema.properties.toString()
																		props = props.replace(" ","")
																		props = props.replace('"', '#')
																		if(
																				props.toLowerCase().contains("#type#:#boolean#")
																		){
																						isAuth = true;
																		}
																}
                            }
                        }
                    }
                }
            }
            if (isAuth) {
                var operation = PatternOperation(abstractOperation, AbstractPatternOperation.AUTHENTICATE)
                operation.path = path

                //Determine input and output values
                var getObject = pathItemObject.get
                log.debug("    " + GsonBuilder().create().toJson(getObject))
                if (getObject.requestBody != null) {
                    //Operation requires some request body
                    var body = MatchingUtil().parseRequestBody(getObject.requestBody, spec)
                    if (body != null) {
                        operation.requiredBody = body
                    }
                }
                if (getObject.parameters != null) {
                    operation.parameters = MatchingUtil().parseParameter(getObject.parameters, spec)
                    log.debug("Found " + operation.parameters.size + " parameters")
                    for (headerparam in MatchingUtil().parseHeaderParameter(getObject.parameters, spec)) {
                        operation.headers.add(Pair(headerparam.get("name").asString, headerparam.getAsJsonObject("schema")))
                    }
                }

                if (getObject.security != null) {
                    var header = MatchingUtil().parseApiKey(getObject.security, spec)
                    if (header != null) {
                        operation.headers.add(header)
                    }
                }
                return operation
            }
        }
        return null
    }

}
