package matching.units

import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import de.tuberlin.mcc.openapispecification.*
import de.tuberlin.mcc.patternconfiguration.AbstractOperation
import io.ktor.http.ContentType
import mapping.PatternOperation
import matching.MatchingUnit
import matching.MatchingUtil
import matching.ReferenceResolver
import org.slf4j.LoggerFactory
import patternconfiguration.AbstractPatternOperation

class CreateMatchingUnit : MatchingUnit{

    val log = LoggerFactory.getLogger("CreateMatchingUnit");

    override fun getSupportedOperation(): String {
        return AbstractPatternOperation.CREATE.name;
    }

    override fun match(pathItemObject: PathItemObject, abstractOperation: AbstractOperation, spec: OpenAPISPecifcation, path: String): PatternOperation? {
        if (pathItemObject.post != null) {
            var operation = PatternOperation(abstractOperation, AbstractPatternOperation.CREATE)
            operation.path = path

            //Determine input and output values
            var postObject = pathItemObject.post
            log.debug("    " + GsonBuilder().create().toJson(postObject))
            if (postObject.requestBody != null) {
                //Operation requires some request body
                var body = MatchingUtil().parseRequestBody(postObject.requestBody, spec)
                if (body != null) {
                    operation.requiredBody = body
                }
            }
            if (postObject.parameters != null) {
                operation.parameters = MatchingUtil().parseParameter(postObject.parameters, spec)
                for (headerparam in MatchingUtil().parseHeaderParameter(postObject.parameters, spec)) {
                    operation.headers.add(Pair(headerparam.get("name").asString, headerparam.getAsJsonObject("schema")))
                }
            }
            if (postObject.security != null) {
                var header = MatchingUtil().parseApiKey(postObject.security, spec)
                if (header != null) {
                    operation.headers.add(header)
                }
            }

            return operation
        }
        return null
    }



}