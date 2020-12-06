package matching.units

import com.google.gson.GsonBuilder
import de.tuberlin.mcc.openapispecification.OpenAPISPecifcation
import de.tuberlin.mcc.openapispecification.PathItemObject
import de.tuberlin.mcc.patternconfiguration.AbstractOperation
import io.ktor.http.ContentType
import mapping.PatternOperation
import matching.MatchingUnit
import matching.MatchingUtil
import org.slf4j.LoggerFactory
import patternconfiguration.AbstractPatternOperation

class OptionsMatchingUnit : MatchingUnit{

    val log = LoggerFactory.getLogger("OptionsMatchingUnit");

    override fun getSupportedOperation(): String {
        return AbstractPatternOperation.CONTROL.name;
    }

    override fun match(pathItemObject: PathItemObject, abstractOperation: AbstractOperation, spec: OpenAPISPecifcation, path: String): PatternOperation? {
        if (pathItemObject.options != null) {
            var operation = PatternOperation(abstractOperation, AbstractPatternOperation.CONTROL)
            operation.path = path

            //Determine input and output values
            var optionsObject = pathItemObject.options
            log.debug("    " + GsonBuilder().create().toJson(optionsObject))
            if (optionsObject.requestBody != null) {
                //Operation requires some request body
                var body = MatchingUtil().parseRequestBody(optionsObject.requestBody, spec)
                if (body != null) {
                    operation.requiredBody = body
                }
            }
            if (optionsObject.parameters != null) {
                operation.parameters = MatchingUtil().parseParameter(optionsObject.parameters, spec)
                for (headerparam in MatchingUtil().parseHeaderParameter(optionsObject.parameters, spec)) {
                    operation.headers.add(Pair(headerparam.get("name").asString, headerparam.getAsJsonObject("schema")))
                }
            }

            if (optionsObject.security != null) {
                var header = MatchingUtil().parseApiKey(optionsObject.security, spec)
                if (header != null) {
                    operation.headers.add(header)
                }
            }

            return operation
        }
        return null
    }

}
