<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthrequest.cfc $
$Id: oauthrequest.cfc 1225 2010-06-07 10:25:05Z derrick13 $
Description:
============
	OAuth request

License:
============
Copyright 2008 CONTENS Software GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

History:
============
08/12/08 - Chris Blackwell: changed generateTimestamp()
	use CreateObject("java", "java.util.Date").getTime() instead of getTickCount (OpenBlueDragon compatibility)
--->

<cfcomponent displayname="oauthrequest">

	<cfset variables.sHttpMethod = "">
	<cfset variables.sHttpURL = "">
	<cfset variables.stParameters = StructNew()>
	<cfset variables.stParameters["paramKeys"] = ArrayNew(1)>
	<cfset variables.stParameters["paramValues"] = ArrayNew(1)>
	<cfset variables.sOAuthVersion = "">
	<!--- utility functions --->
	<cfset variables.oUtil = CreateObject("component","oauthutil").init()>

	<cffunction name="init" returntype="oauthrequest" output="false">
		<cfargument name="sHttpMethod" required="true" type="string" hint="request method">
		<cfargument name="sHttpURL" required="true" type="string" hint="request URL">
		<cfargument name="stParameters"	required="false" type="struct" hint="request parameters"	default="#StructNew()#">
		<cfargument name="aParameterKeys"	required="false" type="array" hint="request parameters"	default="#ArrayNew(1)#">
		<cfargument name="aParameterValues"	required="false" type="array" hint="request parameters"	default="#ArrayNew(1)#">
		<cfargument name="sOAuthVersion" required="false"	type="string" hint="OAuth protocol version" default="1.0">

		<cfset var bVersionParameterSupplied = false>
		<cfset var iParamCounter = 0>

		<cfset setHttpMethod(arguments.sHttpMethod)>
    	<cfset setHttpURL(arguments.sHttpURL)>
		<!--- possible to initialize with struct or key/value-arrays --->
		<cfif NOT StructIsEmpty(arguments.stParameters)>
			<cfset setParameters(stParameters = arguments.stParameters)>
		<cfelse>
			<cfset setParameters(aKeys = arguments.aParameterKeys, aValues = arguments.aParameterValues)>
		</cfif>

		<cfif StructKeyExists(arguments.stParameters, "oauth_version")>
			<cfset setVersion(arguments.stParameters.oauth_version)>
			<cfset bVersionParameterSupplied = true>
		<!--- check for the oauth_version parameters in the array --->
		<cfelseif ArrayLen(arguments.aParameterKeys) GT 0 AND ArrayLen(arguments.aParameterKeys) EQ ArrayLen(arguments.aParameterValues)>
			<cfloop from="1" to="#ArrayLen(arguments.aParameterKeys)#" index="iParamCounter">
				<cfif arguments.aParameterKeys[iParamCounter] EQ "oauth_version"
						AND Len(arguments.aParameterValues[iParamCounter])>
					<cfset setVersion(arguments.aParameterValues[iParamCounter])>
					<cfset setParameter(sKey = "oauth_version", sValue = arguments.aParameterValues[iParamCounter])>
					<cfset bVersionParameterSupplied = true>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>
		<!--- set default oauth_version value --->
		<cfif NOT bVersionParameterSupplied>
			<cfset setVersion(arguments.sOAuthVersion)>
		</cfif>

		<cfreturn this>
	</cffunction>

	<cffunction name="getHttpMethod" access="public" returntype="string">
		<cfreturn variables.sHttpMethod>
	</cffunction>
	<cffunction name="setHttpMethod" access="public" returntype="void">
		<cfargument name="sHttpMethod" type="string" required="yes">
		<cfset variables.sHttpMethod = arguments.sHttpMethod>
	</cffunction>

	<cffunction name="getHttpURL" access="public" returntype="string">
		<cfreturn variables.sHttpURL>
	</cffunction>
	<cffunction name="setHttpURL" access="public" returntype="void">
		<cfargument name="sHttpURL" type="string" required="yes">
		<cfset variables.sHttpURL = arguments.sHttpURL>
	</cffunction>

	<cffunction name="getParameters" access="public" returntype="struct">
		<cfreturn variables.stParameters>
	</cffunction>
	<cffunction name="getParameterKeys" access="public" returntype="array">
		<cfreturn variables.stParameters["paramKeys"]>
	</cffunction>
	<cffunction name="getParameterValues" access="public" returntype="array">
		<cfreturn variables.stParameters["paramValues"]>
	</cffunction>
	<cffunction name="setParameters" access="public" returntype="void">
		<cfargument name="stParameters" type="struct" required="false" default="#StructNew()#">
		<cfargument name="aParameterKeys" type="array" required="false" default="#ArrayNew(1)#">
		<cfargument name="aParameterValues" type="array" required="false" default="#ArrayNew(1)#">

		<cfset var i = 0>
		<cfset var aTempKeys = "">

		<cfif StructKeyExists(arguments.stParameters, "paramKeys") AND StructKeyExists(arguments.stParameters, "paramValues")>
			<cfloop from="1" to="#ArrayLen(arguments.stParameters['paramKeys'])#" index="i">
				<cfset setParameter(sKey = arguments.stParameters['paramKeys'][i], sValue = arguments.stParameters['paramValues'][i])>
			</cfloop>
		<cfelseif ArrayLen(arguments.aParameterKeys) IS 0 AND ArrayLen(arguments.aParameterValues) IS 0>
			<cfset aTempKeys = StructKeyArray(arguments.stParameters)>
			<cfloop from="1" to="#ArrayLen(aTempKeys)#" index="i">
				<cfset setParameter(sKey = aTempKeys[i], sValue = arguments.stParameters[aTempKeys[i]])>
			</cfloop>
		<cfelse>
			<cfloop from="1" to="#ArrayLen(arguments.aParameterKeys)#" index="i">
				<cfset setParameter(sKey = aParameterKeys[i], sValue = aParameterValues[i])>
			</cfloop>
		</cfif>
	</cffunction>
	<cffunction name="setParameter" access="public" returntype="void" hint="sets parameter value">
		<cfargument name="sKey" type="string" required="true" hint="parameter name">
		<cfargument name="sValue" type="string" required="true" hint="parameter value">
		<cfset ArrayAppend(variables.stParameters["paramKeys"], lcase(arguments.sKey))>
		<cfset ArrayAppend(variables.stParameters["paramValues"], arguments.sValue)>
	</cffunction>
	<cffunction name="getParameter" access="public" returntype="any" hint="retrieves paramater value">
		<cfargument name="sParameterName" 	type="string"	required="true"	hint="parameter name">
		<cfset var sResult = "">
		<cfset var aKeys = getParameterKeys()>
		<cfset var aValues = getParameterValues()>
		<cfset var i = 0>

		<cfloop from="1" to="#ArrayLen(aKeys)#" index="i">
			<cfif CompareNoCase(aKeys[i],arguments.sParameterName) IS 0>
			<!--- <cfif CompareNoCase(aKeys[i],arguments.sParameterName) IS 0> --->
				<!--- multiple values possible ? --->
				<!--- <cfif ListLen(aValues[i]) GT 1>

					<cfreturn ListFirst(aValues[i])>
				<cfelse>
					<cfreturn aValues[i]>
				</cfif> --->
				<cfreturn aValues[i]>
			</cfif>
		</cfloop>

		<cfreturn sResult>
	</cffunction>
	<cffunction name="removeParameter" access="public" returntype="void" hint="retrieves paramater value">
		<cfargument name="sParameterName" 	type="string"	required="true"	hint="parameter name">
		<cfset var aOldKeys = getParameterKeys()>
		<cfset var aOldValues = getParameterValues()>
		<cfset var aNewKeys = ArrayNew(1)>
		<cfset var aNewValues = ArrayNew(1)>
		<cfset var i = 0>

		<cfloop from="1" to="#ArrayLen(aOldKeys)#" index="i">
			<cfif Compare(aOldKeys[i],arguments.sParameterName) NEQ 0>
				<cfset ArrayAppend(aNewKeys, aOldKeys[i])>
				<cfset ArrayAppend(aNewValues, aOldValues[i])>
			</cfif>
		</cfloop>
		<!--- remove old parameters --->
		<cfset clearParameters()>
		<!--- set new values --->
		<cfset setParameters(aParameterKeys = aNewKeys, aParameterValues = aNewValues)>
	</cffunction>
	<cffunction name="updateParameter" access="public" returntype="void">
		<cfargument name="sParameterName" 	type="string"	required="true"	hint="parameter name">
		<cfargument name="sParameterValue" 	type="string"	required="true"	hint="parameter value">

		<cfset var i = 0>

		<cfloop from="1" to="#ArrayLen(variables.stParameters['paramValues'])#" index="i">
			<cfif Compare(variables.stParameters['paramValues'][i], arguments.sParameterName) IS 0>
				<cfset variables.stParameters['paramValues'][i] = arguments.sParameterValue>
				<cfreturn>
			</cfif>
		</cfloop>
		<!--- none found, add as new parameter --->
		<cfset setParameter(sKey = arguments.sParameterName, sValue = arguments.sParameterValue)>
	</cffunction>
	<cffunction name="clearParameters" access="public" returntype="void">
		<cfset variables.stParameters["paramKeys"] = ArrayNew(1)>
		<cfset variables.stParameters["paramValues"] = ArrayNew(1)>
	</cffunction>

	<cffunction name="getVersion" access="public" returntype="string" hint="version">
		<cfreturn variables.sOAuthVersion>
	</cffunction>
	<cffunction name="setVersion" access="public" returntype="void">
		<cfargument name="sOAuthVersion" type="string" required="yes">
		<cfset variables.sOAuthVersion = arguments.sOAuthVersion>
	</cffunction>

	<cffunction name="isEmpty" access="public" returntype="boolean">
		<cfset var bResult = false>
		<cfif Len(getHttpMethod()) IS 0 AND Len(getHttpURL()) IS 0>
			<cfset bResult = true>
		</cfif>
		<cfreturn bResult>
	</cffunction>

	<cffunction name="createEmptyRequest" returntype="oauthrequest" access="public">
		<cfset var oResult = init(sHttpMethod = "", sHttpURL = "")>
		<cfreturn oResult>
	</cffunction>

	<!--- attempt to build up a request from what was passed to the server --->
	<cffunction name="fromRequest" access="public" returntype="oauthrequest">
		<cfargument name="sHttpMethod" required="false" type="string" default="">
		<cfargument name="sHttpURL" required="false" type="string" default="">
		<cfargument name="stParameters" required="false" type="struct" default="#StructNew()#"/>

		<cfset var stRequestHeaders = StructNew()>
		<cfset var oResultRequest = 0>
		<cfset var stHeaderParameters = StructNew()>
		<cfset var stRequestParameters = StructNew()>
		<cfset var stTempParameters = StructNew()>

		<cfif Len(arguments.sHttpMethod) IS 0>
    		<cfset variables.sHttpMethod = cgi.request_method>
		<cfelse>
			<cfset variables.sHttpMethod = arguments.sHttpMethod>
		</cfif>

		<cfif Len(arguments.sHttpURL) IS 0>
			<cfset variables.sHttpURL = "http://" & cgi.http_host & cgi.path_info>
		<cfelse>
			<cfset variables.sHttpURL = arguments.sHttpURL>
		</cfif>
	    <!--- get Authorization: header --->
    	<cfset stRequestHeaders = GetHttpRequestData().headers>

	    <!--- let the library user override things however they'd like, if they know
	    	which parameters to use then go for it, for example XMLRPC might want to do this --->
		<cfif NOT StructIsEmpty(arguments.stParameters)>
			<cfset oResultRequest = CreateObject("component", "oauthrequest").init(
				sHttpMethod = variables.sHttpMethod,
				sHttpURL = variables.sHttpURL,
				stParameters = arguments.stParameters)>

	    <!--- next check for the auth header, we need to do some extra stuff
		    if that is the case, namely suck in the parameters from GET or POST
		    so that we can include them in the signature --->
	    <cfelseif StructKeyExists(stRequestHeaders, "Authorization") AND
		  Left(StructFind(stRequestHeaders, "Authorization"), 5) EQ "OAuth">
			<cfset stHeaderParameters = splitHeader(StructFind(stRequestHeaders, "Authorization"))>

			<cfif variables.sHttpMethod EQ "GET">
				<cfset stRequestParameters = URL>
			<cfelseif variables.sHttpMethod EQ "POST">
				<cfset stRequestParameters = FORM>
			</cfif>

			<cfset stTempParameters = stRequestParameters>
			<cfset StructAppend(stTempParameters, stHeaderParameters)>
			<cfset StructAppend(stTempParameters, stRequestParameters)>
			<cfset oResultRequest = CreateObject("component","oauthrequest").init(
				sHttpMethod = variables.sHttpMethod,
				sHttpURL = variableshttpURL,
				stParamaters = stTempParameters)>

		<cfelseif variables.sHttpMethod EQ "GET">
    		<cfset oResultRequest = CreateObject("component","oauthrequest").init(
				sHttpMethod = variables.sHttpMethod,
				sHttpURL = variables.sHttpURL,
				stParameters = URL)>
		<cfelseif variables.sHttpMethod EQ "POST">
    		<cfset oResultRequest = CreateObject("component","oauthrequest").init(
				sHttpMethod = variables.sHttpMethod,
				sHttpURL = variables.sHttpURL,
				stParameters = FORM)>
		</cfif>

		<cfreturn oResultRequest>
	</cffunction>

	<!--- helper function to set up the request --->
	<cffunction name="fromConsumerAndToken" access="public" returntype="oauthrequest">
		<cfargument name="oConsumer"	required="true" type="oauthconsumer">
		<cfargument name="oToken" 		required="true" type="oauthtoken">
		<cfargument name="sHttpMethod" 	required="true" type="string">
		<cfargument name="sHttpURL" 	required="true"	type="string">
		<cfargument name="sCallbackURL" 	required="false" default=""	type="string">
		<cfargument name="stParameters"	required="false" type="struct" default="#StructNew()#">

		<cfset var oResultRequest = createEmptyRequest()>
		<cfset var stNewParameters = StructNew()>
		<cfset var stDefault = StructNew()>

		<cfset stDefault["oauth_version"] = getVersion()>
		<cfset stDefault["oauth_nonce"] = generateNonce()>
		<cfset stDefault["oauth_timestamp"] = generateTimestamp()>
		<cfset stDefault["oauth_consumer_key"] = arguments.oConsumer.getKey()>
		
		<cfif arguments.sCallbackURL NEQ ''>
		<cfset stDefault["oauth_callback"] = arguments.sCallbackURL />
		</cfif>

		<cfset stNewParameters = arguments.stParameters>
		<cfset StructAppend(stNewParameters, stDefault, "yes")>

		<cfif NOT arguments.oToken.isEmpty()>
			<cfset stNewParameters["oauth_token"] = arguments.oToken.getKey()>
		</cfif>
		<cfset oResultRequest = CreateObject("component", "oauthrequest").init(
			sHttpMethod = arguments.sHttpMethod,
			sHttpURL = arguments.sHttpURL,
			stParameters = stNewParameters)>
		<cfreturn oResultRequest>
	</cffunction>


	<cffunction name="getNormalizedHttpMethod" access="public" returntype="string">
		<cfreturn UCase(variables.sHttpMethod)>
	</cffunction>

   <!--- parses the url and rebuilds it to be [scheme://host/path] --->
	<cffunction name="getNormalizedHttpURL" access="public" returntype="string" output="false">
		<cfargument name="sScheme" type="string" required="false" default="http://">
		<cfargument name="iPort" type="string" required="false" default="" hint="not used currently">

		<cfset var sResult = "">
		<cfset var sURLScheme = arguments.sScheme>
		<cfset var sRequestPort = "">
		<!--- "9.1.2.Construct Request URL":default ports 80(HTTP) & 443(HTTPS) must be excluded,else use specified port --->
		<cfif IsNumeric(arguments.iPort) AND arguments.iPort GT 0>
			<cfif ( Compare(sURLScheme, "https://") IS 0 AND arguments.iPort NEQ 443 )
					OR
				  ( Compare(sURLScheme, "http://") IS 0 AND arguments.iPort NEQ 80 )>
				  <cfset sRequestPort = ":#arguments.iPort#">
			</cfif>
		</cfif>

		<cfif Len(variables.sHttpURL) IS 0><!--- maybe use script_name instead of path_info --->
			<cfset sResult = sURLScheme & cgi.server_name & sRequestPort & cgi.path_info>
		<cfelse>
			<cfset sResult = variables.sHttpURL>
		</cfif>
		<cfreturn sResult>
	</cffunction>

	<cffunction name="getSignableParametersOld" access="public" returntype="string">
		<cfset var aResult = ArrayNew(1)>
		<cfset var sResult = "">
		<cfset var sKey = "">
		<cfset var i = 0>
		<cfset var aKeys = getParameterKeys()>
		<cfset var aValues = getParameterValues()>
		<cfset ArraySort(aKeys, "textnocase")>

		<cfloop from="1" to="#ArrayLen(aKeys)#" index="sKey">
			<!--- skip 'oauth_signature'-parameter --->
			<cfif sKey NEQ "oauth_signature">
				<cfset 	ArrayAppend(aResult, sKey & "=" & StructFind(variables.stParameters, sKey) )>
			</cfif>
		</cfloop>

		<cfset ArraySort(aResult, "textnocase")>
		<cfset sResult = ArrayToList(aResult, "&")>
		<cfreturn sResult>
	</cffunction>

	<!--- return a string that consists of all the parameters that need to be signed --->
	<cffunction name="getSignableParameters" access="public" returntype="string">
		<cfset var outerCnt = 0>
		<cfset var innerCnt = 0>
		<cfset var sTemp = "">
		<cfset var sTempLower = "">
		<cfset var stKeyValues = StructNew()>
		<cfset var aResult = ArrayNew(1)>
		<cfset var aTemp = ArrayNew(1)>
		<cfset var aResultTemp = ArrayNew(1)>
		<cfset var aSortedKeys = ArrayNew(1)>
		<cfset var aParameterKeys = "">
		<cfset var aParameterValues = "">

		<!--- old signature not needed --->
		<cfset removeParameter("oauth_signature")>

		<cfset aParameterKeys = getParameterKeys()>
		<cfset aParameterValues = getParameterValues()>

		<cfloop from="1" to="#ArrayLen(aParameterKeys)#" index="outerCnt">
			<cfif StructKeyExists(stKeyValues, aParameterKeys[outerCnt])>
				<cfset aTemp = stKeyValues[aParameterKeys[outerCnt]]>
				<cfset ArrayAppend(aTemp, aParameterValues[outerCnt])>
				<cfset StructUpdate(stKeyValues, aParameterKeys[outerCnt], aTemp)>
			<cfelse>
				<cfset aTemp = ArrayNew(1)>
				<cfset ArrayAppend(aTemp, aParameterValues[outerCnt])>
				<cfset StructInsert(stKeyValues, aParameterKeys[outerCnt], aTemp)>
			</cfif>
		</cfloop>
		<!--- use sorted keys --->
		<cfset aSortedKeys = StructKeyArray(stKeyValues)>
		<cfset ArraySort(aSortedKeys, "text", "asc")>

		<cfloop from="1" to="#ArrayLen(aSortedKeys)#" index="outerCnt">
			<cfset sTemp = aSortedKeys[outerCnt]>
			<!--- retrieve possible values for this key & sort them --->
			<cfset aTemp = stKeyValues[sTemp]>
			<cfset ArraySort(aTemp, "text", "asc")>

			<cfset aResultTemp = ArrayNew(1)>
			<cfloop from="1" to="#ArrayLen(aTemp)#" index="innerCnt">
				<cfset ArrayAppend(aResultTemp, "#variables.oUtil.encodePercent(sTemp)#=#variables.oUtil.encodePercent(aTemp[innerCnt])#")>
			</cfloop>
			<cfset ArrayAppend(aResult, ArrayToList(aResultTemp, "&"))>
		</cfloop>

		<cfreturn ArrayToList(aResult,"&")>
	</cffunction>

	<!--- builds an URL usable for a GET request --->
	<cffunction name="toURL" access="public" output="false" returntype="string">
		<cfset var sResult = getNormalizedHttpURL() & "?">
		<cfset sResult = sResult & toPostData()>
		<cfreturn sResult>
	</cffunction>

  	<!--- builds the data one would send in a POST request, parameters are sorted alphabetically & url encoded --->
	<cffunction name="toPostData" access="public" returntype="string">
		<cfset var aTotal = ArrayNew(1)>
		<cfset var sResult = "">
		<cfset var aResultTemp = ArrayNew(1)>
		<cfset var aParameterKeys = getParameterKeys()>
		<cfset var aParameterValues = getParameterValues()>
		<cfset var stKeyValues = StructNew()>
		<cfset var aSortedKeys = "">
		<cfset var aTemp = "">
		<cfset var sTemp = "">
		<cfset var i = 0>
		<cfset var outerCnt = 1>
		<cfset var innerCnt = 1>

		<!--- extract possible keys and their values --->
		<cfloop from="1" to="#ArrayLen(aParameterKeys)#" index="outerCnt">
			<cfif StructKeyExists(stKeyValues, aParameterKeys[outerCnt])>
				<cfset aTemp = stKeyValues[aParameterKeys[outerCnt]]>
				<cfset ArrayAppend(aTemp, aParameterValues[outerCnt])>
				<cfset StructUpdate(stKeyValues, aParameterKeys[outerCnt], aTemp)>
			<cfelse>
				<cfset aTemp = ArrayNew(1)>
				<cfset ArrayAppend(aTemp, aParameterValues[outerCnt])>
				<cfset StructInsert(stKeyValues, aParameterKeys[outerCnt], aTemp)>
			</cfif>
		</cfloop>
		<!--- use sorted keys --->
		<cfset aSortedKeys = StructKeyArray(stKeyValues)>
		<cfset ArraySort(aSortedKeys, "text", "asc")>

		<cfloop from="1" to="#ArrayLen(aSortedKeys)#" index="outerCnt">
			<cfset sTemp = aSortedKeys[outerCnt]>
			<!--- retrieve possible values for this key & sort them --->
			<cfset aTemp = stKeyValues[sTemp]>
			<cfset ArraySort(aTemp, "text", "asc")>

			<cfset aResultTemp = ArrayNew(1)>
			<cfloop from="1" to="#ArrayLen(aTemp)#" index="innerCnt">
				<cfset ArrayAppend(aResultTemp, "#variables.oUtil.encodePercent(sTemp)#=#variables.oUtil.encodePercent(aTemp[innerCnt])#")>
			</cfloop>
			<cfset ArrayAppend(aTotal, ArrayToList(aResultTemp, "&"))>
		</cfloop>

		<cfset sResult = ArrayToList(aTotal, "&")>

		<cfreturn sResult>
	</cffunction>

  	<!--- builds the Authorization: header --->
	<cffunction name="toHeader" access="public" returntype="string" output="false">
		<cfargument name="sHeaderRealm" default="" required="false" type="string">
    <cfargument name="includeHeaderName" default=true />

		<cfset var sRealm = arguments.sHeaderRealm>
		<cfset var sResult = "">
		<cfset var aTotal = ArrayNew(1)>
		<cfset var i = 0>
		<cfset var aKeys = getParameterKeys()>
		<cfset var aValues = getParameterValues()>

    <!--- optional realm parameter --->
    <cfif len(arguments.sHeaderRealm)>
      <cfset ArrayAppend(aTotal,"""realm=""" & sRealm & """")>
    </cfif>

		<cfloop from="1" to="#ArrayLen(aKeys)#" index="i">
			<cfif Left(aKeys[i], 5) EQ "oauth">
				<cfset ArrayAppend(aTotal,
					variables.oUtil.encodePercent(aKeys[i]) & "=""" & variables.oUtil.encodePercent(aValues[i]) & """")>
			</cfif>
		</cfloop>

    <cfset sResult = ArrayToList(aTotal, ",")>
    <cfset sResult = "OAuth #sResult#">

    <cfif arguments.includeHeaderName>
      <cfset sResult = """Authorization: #sResult#">
    </cfif>

		<cfreturn sResult>
	</cffunction>

	<cffunction name="getString" access="public" returntype="string">
		<cfreturn toURL()>
	</cffunction>

	<cffunction name="signRequest" access="public" returntype="void" output="false">
		<cfargument name="oSignatureMethod"	required="true" type="oauthsignaturemethod">
		<cfargument name="oConsumer" 		required="true" type="oauthconsumer">
		<cfargument name="oToken" 			required="true" type="oauthtoken">

		<cfset var sSignature = "">

		<cfset removeParameter(sParameterName = "oauth_signature_method")>
		<cfset removeParameter(sParameterName = "oauth_signature")>

		<cfset setParameter(sKey = "oauth_signature_method", sValue = arguments.oSignatureMethod.getName())>
		
		<cfset sSignature = buildSignature(arguments.oSignatureMethod, arguments.oConsumer, arguments.oToken)>
		<cfset setParameter(sKey = "oauth_signature", sValue = sSignature)>
	</cffunction>

	<!--- build url encoded signature --->
	<cffunction name="signatureBaseString" access="public" returntype="string">
		<cfset var aResult = ArrayNew(1)>
		<cfset ArrayAppend( aResult, variables.oUtil.encodePercent( getNormalizedHttpMethod() ) )>
		<cfset ArrayAppend( aResult, variables.oUtil.encodePercent( getNormalizedHttpURL() ) )>
		<cfset ArrayAppend( aResult, variables.oUtil.encodePercent( getSignableParameters() ) )>

		<cfreturn ArrayToList(aResult, "&")>
	</cffunction>

	<cffunction name="buildSignature" access="public" returntype="string" output="false">
		<cfargument name="oSignatureMethod"	required="true" type="oauthsignaturemethod">
		<cfargument name="oConsumer" 		required="true" type="oauthconsumer">
		<cfargument name="oToken" 			required="true" type="oauthtoken">

		<cfset var sSignature = arguments.oSignatureMethod.buildSignature(this, arguments.oConsumer, arguments.oToken)>

		<cfreturn sSignature>
	</cffunction>

	<!--- util function: current timestamp --->
	<cffunction name="generateTimestamp" access="public" returntype="numeric">
		<cfset var tc = CreateObject("java", "java.util.Date").getTime()>
		<cfreturn Int(tc / 1000)>
	</cffunction>

	<!--- util function: current nonce --->
	<cffunction name="generateNonce" access="public" returntype="string" output="false" hint="generate nonce value">
		<cfset var iMin = 0>
		<cfset var iMax = CreateObject("java","java.lang.Integer").MAX_VALUE>
		<cfset var sToEncode = generateTimestamp() & RandRange(iMin, iMax)>

		<cfreturn Hash(sToEncode, "SHA")/>
	</cffunction>
	
	<!---
		Additional of secondary method for generateNonce that plays nicely with OpenBD.
		Thanks to Craig328 for supplying this.
		(http://www.mattgifford.co.uk/managing-multiple-twitter-users-authentication-with-monkehtweet/comment-page-1#comment-58828)
	--->
	<!---
	<cffunction name="generateNonce" access="public" returntype="string" output="false" hint="generate nonce value">
		<cfset var iMin = 0>
		<cfset var iMax = 1000000000>
		<cfset var sToEncode = generateTimestamp() & RandRange(iMin, iMax, "SHA1PRNG")>
		
		<cfreturn Hash(sToEncode, "SHA")/>
	</cffunction>
	--->

	<!--- util function for turning the Authorization: header into parameters, has to do some unescaping --->
	<cffunction name="splitHeader" access="private" output="false" returntype="struct">
  		<cfargument name="sHeader" type="string" required="true" hint="authorization request header">

		<cfset var aHeaderParts = ArrayNew(1)>
		<cfset var aParameterParts = ArrayNew(1)>
		<cfset var stResult = StructNew()>
    	<cfset var sParam = "">

		<cfset aHeaderParts = ListToArray(arguments.sHeader, ",")>

		<cfloop collection="#aHeaderParts#" item="sParam">
			<cfset sParam = LTrim(sParam)>

		    <cfif Left(sParam, 5) EQ "oauth">
			    <cfset aParameterParts = ListToArray(sParam, "=")>
			    <cfset stResult[aParameterParts[1]] = variables.oUtil.decodePercent(aParameterParts[2])>
		    </cfif>
		</cfloop>

		<cfreturn stResult>
	</cffunction>

</cfcomponent>
