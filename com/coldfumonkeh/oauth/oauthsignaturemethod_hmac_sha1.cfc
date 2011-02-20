<!---
$HeadURL: https://oauth.googlecode.com/svn/code/coldfusion/oauth/oauthsignaturemethod_hmac_sha1.cfc $
$Id: oauthsignaturemethod_hmac_sha1.cfc 1228 2010-06-09 10:43:22Z derrick13 $
Description:
============
	OAuth signaturemethod "HMAC SHA1"

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
08/11/08 - Chris Blackwell: added java.net.URLEncoder code, see
	http://code.google.com/p/oauth/issues/detail?id=35
--->

<cfcomponent extends="oauthsignaturemethod" displayname="oauthsignaturemethod_hmac_sha1" hint="signature method using HMAC-SHA1">

	<!--- returns the signature name --->
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn "HMAC-SHA1">
	</cffunction>

	<!--- builds a SHA-1 signature --->
	<cffunction name="buildSignature" access="public" returntype="string" output="false">
		<cfargument name="oRequest"		required="true" type="oauthrequest">
		<cfargument name="oConsumer"	required="true" type="oauthconsumer">
		<cfargument name="oToken"		required="true" type="oauthtoken">

		<cfset var aSignature = ArrayNew(1)>
		<cfset var sKey = "">
		<cfset var sResult = "">
		<cfset var sHashed = "">
		<cfset var digest = "">
		<cfset var encoder = CreateObject("component", "oauthutil").init()>

		<cfset ArrayAppend(	aSignature,
							encoder.encodePercent(arguments.oRequest.getNormalizedHttpMethod()) )>
		<cfset ArrayAppend(	aSignature,
							encoder.encodePercent(arguments.oRequest.getNormalizedHttpURL()) )>
		<cfset ArrayAppend(	aSignature,
							encoder.encodePercent(arguments.oRequest.getSignableParameters()) )>

		<cfset sKey = encoder.encodePercent(arguments.oConsumer.getSecret()) & "&" & encoder.encodePercent(arguments.oToken.getSecret())> 
		<cfset sResult = ArrayToList(aSignature, "&")>

		<cfset sHashed = hmac_sha1(
			signKey = sKey,
			signMessage = sResult)>

		<cfreturn sHashed>
	</cffunction>

	<cffunction name="hmac_sha1" returntype="string" access="public">
	   <cfargument name="signKey" type="string" required="true">
	   <cfargument name="signMessage" type="string" required="true">
	   <cfargument name="sFormat" type="string" required="false" default="iso-8859-1">

	   <cfset var jMsg = JavaCast("string", arguments.signMessage).getBytes(arguments.sFormat)>
	   <cfset var jKey = JavaCast("string", arguments.signKey).getBytes(arguments.sFormat)>

	   <cfset var key = createObject("java", "javax.crypto.spec.SecretKeySpec")>
	   <cfset var mac = createObject("java", "javax.crypto.Mac")>

	   <cfset key = key.init(jKey,"HmacSHA1")>

	   <cfset mac = mac.getInstance(key.getAlgorithm())>
	   <cfset mac.init(key)>
	   <cfset mac.update(jMsg)>

	   <cfreturn ToBase64(mac.doFinal())>
	</cffunction>

</cfcomponent>