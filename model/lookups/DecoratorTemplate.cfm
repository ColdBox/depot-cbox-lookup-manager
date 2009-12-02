<cfcomponent extends="transfer.com.TransferDecorator" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Scaffolding Table Config --->
	<cffunction name="gettableConfig" access="public" returntype="struct" output="false" hint="Get the table config for scaffolding">
		<cfreturn instance.tableConfig>
	</cffunction>
	<cffunction name="settableConfig" access="public" returntype="void" output="false" hint="Set the table config for scaffolding">
		<cfargument name="tableConfig" type="struct" required="true">
		<cfset instance.tableConfig = arguments.tableConfig>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="configure" access="private" returntype="void" hint="Constructor code for my decorator">
		<cfscript>
			/* Table Config for scaffolding*/
			var tc = structnew();
			
@tcreplace@
			
			/* Set the config */
			setTableConfig(tc);
		</cfscript>
	</cffunction>
	
</cfcomponent>