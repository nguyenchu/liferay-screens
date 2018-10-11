package com.liferay.mobile.screens.ddl

/**
 * @author Victor Oliveira
 */
import android.util.Patterns

abstract class StringValidator(val errorMessage: String) {
    abstract fun validate(string: String): Boolean
}

class ContainsValidation(val value: String, errorMessage: String): StringValidator(errorMessage) {
    override fun validate(string: String): Boolean = string.contains(value)
}

class NotContainsValidation(val value: String, errorMessage: String): StringValidator(errorMessage) {
    override fun validate(string: String): Boolean = !string.contains(value)
}

class IsEmailValidation(errorMessage: String): StringValidator(errorMessage) {
    override fun validate(string: String): Boolean = Patterns.EMAIL_ADDRESS.matcher(string).matches()
}

class IsUrlValidation(errorMessage: String): StringValidator(errorMessage) {
    override fun validate(string: String): Boolean = Patterns.WEB_URL.matcher(string).matches()
}

class RegexValidation(val regex: Regex, errorMessage: String): StringValidator(errorMessage) {
    override fun validate(string: String): Boolean = regex.matches(string)
}

class DummyValidation: StringValidator("") {
    override fun validate(string: String): Boolean = true
}

class StringValidatorParser {

    fun parseStringValidation(validationMap: Map<String, String>): StringValidator {
        if (validationMap.isEmpty()) {
            return DummyValidation()
        }

        val errorMessage = validationMap["error"] as? String ?: ""
        val expression = validationMap["expression"] as? String ?: ""

        if (expression.startsWith("isEmailAddress(")) {
            return IsEmailValidation(errorMessage)
        } else if (expression.startsWith("isURL(")) {
            return IsUrlValidation(errorMessage)
        } else if (expression.startsWith("contains(")) {
            return executeRegexAndGetFirstResult("""contains\(\w+, "(\w*)"\)""", expression) {
                ContainsValidation(it, errorMessage)
            }
        } else if (expression.startsWith("NOT(contains(")) {
            return executeRegexAndGetFirstResult("""NOT\(contains\(\w+, "(\w*)"\)\)""", expression) {
                NotContainsValidation(it, errorMessage)
            }

        } else if (expression.startsWith("match(")) {
            return executeRegexAndGetFirstResult("""match\(\w+, "(\w*)"\)""", expression) {
                RegexValidation(it.toRegex(), errorMessage)
            }
        }

        return DummyValidation()
    }

    private fun executeRegexAndGetFirstResult(stringRegex: String, expression: String,
        and: (String) -> StringValidator): StringValidator {
        val result = stringRegex.toRegex().find(expression)
        return result?.groups?.get(1)?.value?.let(and) ?: DummyValidation()
    }
}