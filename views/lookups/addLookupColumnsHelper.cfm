<!--- matchType --->
<cffunction name="matchType" output="false" access="public" returntype="any" hint="Match DB to CF Types">
	<cfargument name="dbtype"/>
	<cfset var match = "">
	<cfswitch expression="#arguments.dbtype#">
		<cfcase value="bit,tinyint,boolean"><cfset match = "boolean"></cfcase>
		<cfcase value="smallint,mediumint,bigint,int,float,double,decimal"><cfset match = "numeric"></cfcase>
		<cfcase value="varchar,char,nvarchar,text,tinytext,mediumtext,longtext,notes"><cfset match = "string"></cfcase>
		<cfcase value="date,time,year,datetime,timestamp"><cfset match = "date"></cfcase>
		<cfcase value="blob,binary,clob,varbinary,tinyblob,mediumblob,longblob"><cfset match = "binary"></cfcase>
	</cfswitch>
	<cfreturn match>
</cffunction>

<!--- getFKColumns --->
<cffunction name="getFKColumns" output="false" access="public" returntype="any" hint="Get a FK columns">
	<cfargument name="table" type="string" required="true" default="" hint="The FK table"/>
	<cfset var qRel = 0>
	<cfdbinfo datasource="#getDatasource('lookups').getName()#" name="qRel" table="#arguments.table#" type="columns" />
	<cfreturn qRel>
</cffunction>