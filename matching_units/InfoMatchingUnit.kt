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
class InfoMatchingUnit : MatchingUnit{

    val log = LoggerFactory.getLogger("InfoMatchingUnit");

    override fun getSupportedOperation(): String {
        return AbstractPatternOperation.INFO.name;
    }

    override fun match(pathItemObject: PathItemObject, abstractOperation: AbstractOperation, spec: OpenAPISPecifcation, path: String): PatternOperation? {
				var isInfo=false
        if (pathItemObject.get != null) {
						var reqStatus=path.contains("status")
						var reqVersion=path.contains("version")
						var reqInfo=path.contains("info")
						var helperArr=path.split("/")
						var reqCount= helperArr[helperArr.size-1].equals("count") 
						isInfo = reqInfo || reqVersion || reqStatus || reqCount
				    if (isInfo) {
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
