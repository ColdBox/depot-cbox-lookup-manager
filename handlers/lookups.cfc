<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	The lookup handler
----------------------------------------------------------------------->
<cfcomponent name="lookup" 
			 extends="coldbox.system.eventhandler"
			 output="false"
			 hint="This is the lookup builder controller object"
			 autowire="true">

	<!--- Dependencies --->
	<cfproperty name="LookupService" type="model" scope="instance">

	<!--- HANDLER PROPERTIES --->
	<cfset this.PREHANDLER_ONLY = "index,display,dspCreate,dspEdit,addLookup,addLookupColumns,dspConfirmation">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- This init is mandatory, including the super.init(). ---> 
	<cffunction name="init" returntype="Lookups" output="false">
		<cfargument name="controller" type="any">
		<cfscript>
			var qFiles = 0;
			super.init(arguments.controller);
			
			/* Init Instance Variables */
			instance.cssList = "";
			instance.jsList = "";
			instance.handlerPackage = "";
			instance.viewPackage = "";
			
			/* Get CSS Files */
			qFiles = getFiles(getSetting('ApplicationPath') & getSetting('lookups_cssPath'),"*.css");
			instance.cssList = valueList(qFiles.name);
			/* Get js Files */
			qFiles = getFiles(getSetting('ApplicationPath') & getSetting('lookups_jsPath'),"*.js");
			instance.jsList = valueList(qFiles.name);
			/* Handler Package Path */
			instance.handlerPackage = getSetting('lookups_packagePath');
			if( len(instance.handlerPackage) neq 0){
				instance.handlerPackage = instance.handlerPackage & ".";
			} 
			/* View PackagePath */
			instance.viewPackage = getSetting('lookups_packagePath');
			if( len(instance.viewPackage) neq 0 ){
				instance.viewPackage = instance.viewPackage & "/";
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- IMPLICIT EVENTS ------------------------------------------->

	<!--- preHandler --->
	<cffunction name="preHandler" returntype="void" output="false" hint="">
		<cfargument name="Event" type="any" required="yes">
	    <cfscript>
			var rc = event.getCollection();
			var x = 1;
			var cssPath = getSetting('lookups_cssPath') & "/";
			var jsPath = getSetting('lookups_jsPath') & "/";
			/* Get Image Path  */
			rc.imgPath = getSetting('lookups_imgPath');
			/* Global Exit Handler for this handler */
			rc.xehLookupList 	= "#instance.viewPackage#lookups/display";
			/* Load Custom CSS According to settings */
			for(x=1;x lte listlen(instance.cssList);x=x+1){
				$htmlhead('<link rel="stylesheet" type="text/css" href="' & cssPath & listgetAt(instance.cssList,x) & '" />');
			}
			/* Load Custom JS According to settings */
			for(x=1;x lte listlen(instance.jsList);x=x+1){
				$htmlhead('<script type="text/javascript" src="' & jsPath & listgetAt(instance.jsList,x) & '"></script>');	
			}		
		</cfscript> 
	</cffunction>
	
	<!--- index --->
	<cffunction name="index" returntype="void" output="false" hint="Index">
		<cfargument name="Event" type="any" required="yes">
		<cfset display(event)>
	</cffunction>

<!------------------------------------------- PUBLIC EVENTS ------------------------------------------->

	<!--- addLookup --->
	<cffunction name="addLookup" returntype="void" output="false" hint="Show the add lookups screen">
		<cfargument name="Event" type="any" required="yes">
		<cfset var rc = event.getCollection()>
		<cfscript>
			/* Get All DB Tables */
			rc.qTables = getLookupService().getDBTables();
			/* XEH */
			rc.xehAddColumns = "#instance.handlerPackage#lookups/addLookupColumns";
			/* Lookup Variables */
			rc.systemLookups = getSetting("lookups_tables");
			rc.systemLookupsKeys = getSortedLookupKeys();
			/* Set View */
			event.setView('#instance.viewPackage#lookups/addLookup');
		</cfscript>
	</cffunction>

	<!--- addColumns --->
	<cffunction name="addLookupColumns" returntype="void" output="false" hint="Process and show the addition of columns">
		<cfargument name="Event" type="any" required="yes">
		<cfset var rc = event.getCollection()>
		<cfset var x = 1>
		<cfscript>
			/* Selection Validation */
			if( listlen(event.getTrimValue("tables","")) eq 0 ){
				getPlugin("messagebox").setMessage(type="warning", message="No tables selected, please select one.");
				setNextRoute("#instance.handlerPackage#lookups/add");
			}
			/* Prepare Alias Map */
			rc.aliasMap = {};
			for(x=1;x lte listlen(rc.tables); x++){
				rc.aliasMap[listgetAt(rc.tables,x)] = rc[listgetAt(rc.tables,x) & "_class"];
			}
			rc.aliasMapJSON = getPlugin("json").encode(rc.aliasMap);
			/* Get DB Config Data */
			rc.lookupConfig = getLookupService().getDBTableConfigurations(rc.tables,rc);
			/* Setup some list types */
			rc.propertyTypes		= "binary,boolean,date,numeric,UUID,GUID,string";
			rc.pktypes				= "UUID,GUID,string,numeric";
			rc.lookupBooleanTypes 	= "radio,select";
			rc.lookupHTMLTypes 		= "password,richtext,text,textarea";
			/* XEH */
			rc.xehcreateLookups = "#instance.handlerPackage#lookups/createLookups";
			rc.xehAdd = "#instance.handlerPackage#lookups/addLookup";
			rc.xehAddm2m = "#instance.handlerPackage#lookups/m2mrow";
			rc.xehAddo2m = "#instance.handlerPackage#lookups/o2mrow";
			rc.xehTableColumns = "#instance.handlerPackage#lookups/renderTableColumns";
			
			/* Set View */
			event.setView('#instance.viewPackage#lookups/addLookupColumns');
		</cfscript>
	</cffunction>
	
	<!--- createLookups --->
	<cffunction name="createLookups" returntype="void" output="false" hint="Create the lookups">
		<cfargument name="Event" type="any" required="yes">
		<cfset var rc = event.getCollection()>
		<cfscript>	
			/* Setup Config File Locations */
			rc.ConfigFileLocation = getSetting('configFileLocation',true);
			rc.transferConfigPath = locateFilePath(rc.transferConfigPath);
			rc.modelsPath = getSetting("ModelsPath");
			rc.AppMapping = replace(getSetting("AppMapping"),"/",".","all");
			
			/* Create Lookups */
			getLookupService().createLookups(rc.tables,rc);
			
			/* Show Results */
			getPlugin("messagebox").setMessage(type="info", message="Lookups created successfully");
			setNextRoute(route="#instance.viewPackage#lookups/dspConfirmation");
		</cfscript>
	</cffunction>
	
	<!--- createLookupsConfirmation --->
	<cffunction name="dspConfirmation" returntype="void" output="false" hint="Confirmation">
		<cfargument name="Event" type="any" required="yes">
		<cfscript>	
			var rc = event.getCollection();
			/* Set Restart Bit */
			getController().setColdboxInitiated(false);
			event.setView("#instance.viewPackage#lookups/dspConfirmation");		
		</cfscript>
	</cffunction>
	
	<!--- renderm2mRow --->
	<cffunction name="m2mrow" output="false" returntype="void" hint="Render m2m row">
		<cfargument name="Event" type="any" required="yes">
		<cfscript>
			var rc = event.getCollection();
			/* Get All DB Tables */
			rc.qTables = getLookupService().getDBTables();
			/* Re-Inflate Aliases Map */
			rc.aliasMap = getPlugin("json").decode(rc.aliasMap);
			/* Render back results */
			event.renderData(data=renderView('#instance.viewPackage#lookups/m2mRow'));
		</cfscript>
	</cffunction>
	
	<!--- o2mrow --->
	<cffunction name="o2mrow" output="false" returntype="void" hint="Render o2m row">
		<cfargument name="Event" type="any" required="yes">
		<cfscript>
			var rc = event.getCollection();
			/* Get All DB Tables */
			rc.qTables = getLookupService().getDBTables();
			/* Re-Inflate Aliases Map */
			rc.aliasMap = getPlugin("json").decode(rc.aliasMap);
			/* Render back results */
			event.renderData(data=renderView('#instance.viewPackage#lookups/o2mRow'));
		</cfscript>
	</cffunction>
	
	<!--- renderm2mRow --->
	<cffunction name="renderTableColumns" output="false" returntype="void" hint="Rernder JSON m2m table Columns">
		<cfargument name="Event" type="any" required="yes">
		<cfscript>
			var rc = event.getCollection();
			/* Render back results */
			event.renderData(type="JSON",data=getLookupService().getDBColumns(rc.targetTable));
		</cfscript>
	</cffunction>
	
	<!--- Display --->
	<cffunction name="display" output="false" returntype="void" hint="Display System Lookups">
		<cfargument name="Event" type="any">
		<cfscript>
		//Local event reference
		var rc = event.getCollection();
		var key = "";
		
		/* SET XEH */
		rc.xehLookupCreate = "#instance.handlerPackage#lookups/dspCreate";
		rc.xehLookupDelete = "#instance.handlerPackage#lookups/doDelete";
		rc.xehLookupEdit = "#instance.handlerPackage#lookups/dspEdit";
		rc.xehLookupClean = "#instance.handlerPackage#lookups/cleanDictionary";
		rc.xehLookupsAdd = "#instance.handlerPackage#lookups/addLookup";
		
		/* Get System Lookups */
		rc.systemLookups = getSetting("lookups_tables");
		rc.systemLookupsKeys = getSortedLookupKeys();
		
		/* Validate we have lookups */
		if( ArrayLen(rc.systemLookupsKeys) ){
			//Param Choosen Lookup to first in Key Array
			event.paramValue("lookup", rc.systemLookupsKeys[1]);
			//Prepare Lookup's Meta Data Dictionary
			rc.mdDictionary = getLookupService().prepareDictionary(rc.systemLookups[rc.lookup]);
			//Get Lookup Listing
			rc.qListing = getLookupService().getListing(rc.systemLookups[rc.lookup]);
		}
		else{
			event.paramValue("lookup","");
			rc.qListing = Querynew("");
			getPlugin("messagebox").setMessage(type="warning", message="No lookups declared, please declare some first.");
		}
		//Set view to render
		event.setView("#instance.viewPackage#lookups/Listing");
		</cfscript>
	</cffunction>

	<!--- Clean Dictionary --->
	<cffunction name="cleanDictionary" output="false" returntype="void" hint="Clean the MD Dictionary">
		<cfargument name="Event" type="any">
		<cfscript>
			/* Clean's the dictionary */
			getLookupService().cleanDictionary();
			
			/* Messagebox. */
			getPlugin("messagebox").setMessage("info", "Metadata Dictionary Cleaned.");
					
			/* Relocate back to listing */
			setNextEvent("#instance.viewPackage#lookups");
		</cfscript>
	</cffunction>

	<!--- Do Delete --->
	<cffunction name="doDelete" output="false" returntype="void" hint="Delete A Lookup">
		<cfargument name="Event" type="any">
		<cfscript>
		var i = 1;
		var rc = event.getCollection();
		
		/* Get Lookups */
		rc.systemLookups = getSetting("lookups_tables");
		
		//Check that listing sent in
		if ( event.getTrimValue("lookupid","") neq "" ){
			//Loop throught listing and delete objects
			for(i=1; i lte listlen(rc.lookupid); i=i+1){
				//Delete Entry
				getLookupService().delete(rc.systemLookups[rc.lookup],listgetAt(rc.lookupid,i));
			}
			/* Messagebox. */
			getPlugin("messagebox").setMessage("info", "Record(s) Deleted Successfully.");
		}
		else{
			/* Messagebox. */
			getPlugin("messagebox").setMessage("warning", "No Records Selected");
		}
				
		/* Relocate back to listing */
		setNextEvent(event="#instance.handlerPackage#lookups.display",queryString="lookup=#rc.lookup#");
		</cfscript>
	</cffunction>

	<!--- Dsp Create --->
	<cffunction name="dspCreate" output="false" returntype="void" hint="Create Lookup">
		<cfargument name="Event" type="any">
		<cfscript>
		//collection reference
		var rc = event.getCollection();
		var i = 1;
		
		//LookupCheck
		fncLookupCheck(event);
		/* Setup Lookups */
		rc.systemLookups = getSetting("lookups_tables");
		
		/* exit handlers */
		rc.xehLookupCreate = "#instance.handlerPackage#lookups/doCreate";

		//Get Lookup's md Dictionary
		rc.mdDictionary = getlookupService().getDictionary(rc.systemLookups[rc.lookup]);

		//Check Relations
		if ( rc.mdDictionary.hasManyToOne ){
			//Get Lookup Listings
			for (i=1;i lte ArrayLen(rc.mdDictionary.ManyToOneArray); i=i+1){
				structInsert(rc,"q#rc.mdDictionary.ManyToOneArray[i].alias#",getLookupService().getListing(rc.mdDictionary.ManyToOneArray[i].className));
			}
		}
		if ( rc.mdDictionary.hasParentOneToMany ){
			//Get Lookup Listings
			for (i=1;i lte ArrayLen(rc.mdDictionary.ParentOneToManyArray); i=i+1){
				structInsert(rc,"q#rc.mdDictionary.ParentOneToManyArray[i].alias#",getLookupService().getListing(rc.mdDictionary.ParentOneToManyArray[i].className));
			}
		}
		//Set view.
		event.setView("#instance.viewPackage#lookups/Add");
		</cfscript>
	</cffunction>

	<!--- Do Create --->
	<cffunction name="doCreate" output="false" returntype="void" hint="Create Lookup">
		<cfargument name="Event" type="any">
		<cfscript>
		var rc = event.getCollection();
		var oLookup = "";
		var tmpFKTO = "";
		//Get the Transfer Object's Metadata Dictionary
		var mdDictionary = "";
		var i = 1;
		var errors = 0;
		/* LookupCheck */
		fncLookupCheck(event);
		/* Get Lookups */
		rc.systemLookups = getSetting("lookups_tables");
		rc.lookupClass = rc.systemLookups[rc.lookup];
		
		//Metadata
		mdDictionary = getLookupService().getDictionary(rc.lookupClass);
		//Get New Lookup Transfer Object to save
		oLookup = getLookupService().getLookupObject(rc.lookupClass);
		//Populate it with RC data
		getPlugin("beanFactory").populateBean(oLookup);
		/* Validate First, if a validate method exists on the lookup */
		if( structKeyExists(oLookup,"validate") ){
			errors = oLookup.validate();
			if( ArrayLen(errors) ){
				/* MB for error */
				getPlugin("messagebox").setMessage(type="error", messageArray=errors);
				/* Show Creation Form again to fix errors */
				dspCreate(event);
				/* Finalize this event */
				return;
			}
		}

		//Check for FK Relations
		if ( ArrayLen(mdDictionary.ManyToOneArray) ){
			//Loop Through relations
			for ( i=1;i lte ArrayLen(mdDictionary.ManyToOneArray); i=i+1 ){
				if( structKeyExists(rc,"fk_" & mdDictionary.ManyToOneArray[i].alias) AND
				    len(rc["fk_" & mdDictionary.ManyToOneArray[i].alias]) GT 0 ){
					tmpFKTO = getLookupService().getLookupObject(mdDictionary.ManyToOneArray[i].className,rc["fk_"&mdDictionary.ManyToOneArray[i].alias]);
					//add the tmpTO to oLookup
					evaluate("oLookup.set#mdDictionary.ManyToOneArray[i].alias#(tmpFKTO)");
				}
			}
		}
		if ( ArrayLen(mdDictionary.ParentOneToManyArray) ){
			//Loop Through relations
			for ( i=1;i lte ArrayLen(mdDictionary.ParentOneToManyArray); i=i+1 ){
				if( structKeyExists(rc,"fk_"&mdDictionary.ParentOneToManyArray[i].alias) AND
				    len(rc["fk_"&mdDictionary.ParentOneToManyArray[i].alias]) GT 0 ){
					tmpFKTO = getLookupService().getLookupObject(mdDictionary.ParentOneToManyArray[i].className,rc["fk_"&mdDictionary.ParentOneToManyArray[i].alias]);
					//add the tmpTO to oLookup
					evaluate("oLookup.setParent#mdDictionary.ParentOneToManyArray[i].alias#(tmpFKTO)");
				}
			}
		}
		//Tell service to save object
		getLookupService().save(oLookup);	
			
		/* Relocate back to listing */
		setNextEvent(event="#instance.handlerPackage#lookups.display",queryString="lookup=#rc.lookup#");
		</cfscript>
	</cffunction>

	<!--- DspEdit --->
	<cffunction name="dspEdit" output="false" returntype="void" hint="Edit System Lookups">
		<cfargument name="Event" type="any">
		<cfscript>
		var rc = event.getCollection();
		var i = 1;
		var tmpAlias = "";
		
		//LookupCheck
		fncLookupCheck(event);
		rc.systemLookups = getSetting("lookups_tables");
		rc.lookupClass = rc.systemLookups[rc.lookup];
		
		/* exit handlers */
		rc.xehLookupCreate = "#instance.handlerPackage#lookups/doUpdate";
		rc.xehLookupUpdateRelation = "#instance.handlerPackage#lookups/doUpdateRelation";
		rc.xehLookupDelete = "#instance.handlerPackage#lookups/doDelete";
		rc.xehLookupEdit = "#instance.handlerPackage#lookups/dspEdit";
		rc.xehLookupCreateForm = "#instance.handlerPackage#lookups/dspCreate";
		
		//Get the passed id's TO Object
		rc.oLookup = getLookupService().getLookupObject(rc.lookupClass,rc.id);

		//Get Lookup's md Dictionary
		rc.mdDictionary = getLookupService().getDictionary(rc.lookupClass);
		rc.pkValue = evaluate("rc.oLookup.get#rc.mdDictionary.PK#()");

		//Check ManyToOne Relations
		if ( ArrayLen(rc.mdDictionary.ManyToOneArray) ){
			//Get Lookup Listings
			for (i=1;i lte ArrayLen(rc.mdDictionary.ManyToOneArray); i=i+1){
				structInsert(rc,"q#rc.mdDictionary.ManyToOneArray[i].alias#",getLookupService().getListing(rc.mdDictionary.ManyToOneArray[i].className));
			}
		}
		/* Check Parent ONe To Many */
		if ( ArrayLen(rc.mdDictionary.ParentOneToManyArray) ){
			//Get Lookup Listings
			for (i=1;i lte ArrayLen(rc.mdDictionary.ParentOneToManyArray); i=i+1){
				structInsert(rc,"q#rc.mdDictionary.ParentOneToManyArray[i].alias#",getLookupService().getListing(rc.mdDictionary.ParentOneToManyArray[i].className));
			}
		}
		//Check ManyToMany Relations
		if ( rc.mdDictionary.hasManyToMany ){
			for (i=1;i lte ArrayLen(rc.mdDictionary.manyToManyArray); i=i+1){
				tmpAlias = rc.mdDictionary.manyToManyArray[i].alias;
				//Get m2m relation query
				structInsert(rc,"q#tmpAlias#",getLookupService().getListing(rc.mdDictionary.manyToManyArray[i].linkToTO));
				//Get m2m relation Array
				structInsert(rc,"#tmpAlias#Array", evaluate("rc.oLookup.get#tmpAlias#Array()"));
			}
		}
		/* Check ONe To Many Relations */
		if ( rc.mdDictionary.hasOneToMany ){
			for (i=1;i lte ArrayLen(rc.mdDictionary.oneToManyArray); i=i+1){
				tmpAlias = rc.mdDictionary.oneToManyArray[i].alias;
				//Get m2m relation query
				structInsert(rc,"q#tmpAlias#",getLookupService().getJointListing(rc.lookupClass,rc.mdDictionary.oneToManyArray[i].linkToClass,rc.id));
				structInsert(rc,"md#tmpAlias#",getLookupService().prepareDictionary(rc.mdDictionary.oneToManyArray[i].linkToClass));
			}
		}
		//view to display
		event.setView("#instance.viewPackage#lookups/Edit");
		</cfscript>
	</cffunction>

	<!--- Do Update --->
	<cffunction name="doUpdate" output="false" returntype="void" hint="Update Lookup">
		<cfargument name="Event" type="any">
		<cfscript>
			var rc = event.getCollection();
			var oLookup = "";
			var tmpFKTO = "";
			//Get the Transfer Object's Metadata Dictionary
			var mdDictionary = "";
			var i = 1;

			//LookupCheck
			fncLookupCheck(event);
			rc.systemLookups = getSetting("lookups_tables");
			rc.lookupClass = rc.systemLookups[rc.lookup];
		
			//Metadata
			mdDictionary = getLookupService().getDictionary(rc.lookupClass);
			//Get Lookup Transfer Object to update
			oLookup = getLookupService().getLookupObject(rc.lookupClass, rc.id);
			//Populate it with RC data
			getPlugin("beanFactory").populateBean(oLookup);
			
			//Check for FK Relations
			if ( ArrayLen(mdDictionary.ManyToOneArray) ){
				//Loop Through relations
				for ( i=1;i lte ArrayLen(mdDictionary.ManyToOneArray); i=i+1 ){
					if( structKeyExists(rc,"fk_" & mdDictionary.ManyToOneArray[i].alias) AND
				    len(rc["fk_" & mdDictionary.ManyToOneArray[i].alias]) GT 0 ){
						tmpFKTO = getLookupService().getLookupObject(mdDictionary.ManyToOneArray[i].className,rc["fk_"&mdDictionary.ManyToOneArray[i].alias]);
						//add the tmpTO to current oLookup before saving.
						evaluate("oLookup.set#mdDictionary.ManyToOneArray[i].alias#(tmpFKTO)");
					}
				}
			}
			if ( ArrayLen(mdDictionary.ParentOneToManyArray) ){
				//Loop Through relations
				for ( i=1;i lte ArrayLen(mdDictionary.ParentOneToManyArray); i=i+1 ){
					if( structKeyExists(rc,"fk_" & mdDictionary.ParentOneToManyArray[i].alias) AND
				    len(rc["fk_" & mdDictionary.ParentOneToManyArray[i].alias]) GT 0 ){
						tmpFKTO = getLookupService().getLookupObject(mdDictionary.ParentOneToManyArray[i].className,rc["fk_"&mdDictionary.ParentOneToManyArray[i].alias]);
						//add the tmpTO to oLookup
						evaluate("oLookup.setParent#mdDictionary.ParentOneToManyArray[i].alias#(tmpFKTO)");
					}
				}
			}

			//Save Record(s)
			getLookupService().save(oLookup);
			/* Relocate back to listing */
			setNextEvent(event="#instance.handlerPackage#lookups.display",queryString="lookup=#rc.lookup#");
		</cfscript>
	</cffunction>

	<!--- Do Update Relation --->
	<cffunction name="doUpdateRelation" output="false" returntype="void" hint="Update a TO's m2m relation">
		<cfargument name="Event" type="any">
		<cfscript>
			//Local Variables
			var rc = event.getCollection();
			var mdDictionary = "";
			var oLookup = "";
			var oRelation = "";
			var i = 1;
			var deleteRelationList = "";
			
			/* Incoming Args: lookup, Lookup id, addrelation[boolean], linkTO, linkAlias, m2m_{alias} = listing */

			//LookupCheck
			fncLookupCheck(event);
			rc.systemLookups = getSetting("lookups_tables");
			rc.lookupClass = rc.systemLookups[rc.lookup];
		
			//Get Lookup Transfer Object to update
			oLookup = getLookupService().getLookupObject(rc.lookupClass, rc.id);
			
			//Metadata
			mdDictionary = getLookupService().getDictionary(rc.lookupClass);

			//Adding or Deleting
			if ( event.getValue("addRelation",false) ){
				//Get the relation object
				oRelation = getLookupService().getLookupObject(rc.linkTO, rc["m2m_#rc.linkAlias#"]);
				//Check if it is already in the collection
				if ( not evaluate("oLookup.contains#rc.linkAlias#(oRelation)") ){
					//Add Relation to parent
					evaluate("oLookup.add#rc.linkAlias#(oRelation)");
				}
			}
			else{
				//Del Param
				event.paramValue("m2m_#rc.linkAlias#_id","");
				deleteRelationList = rc["m2m_#rc.linkAlias#_id"];
				//Remove Relations
				for (i=1; i lte listlen(deleteRelationList); i=i+1){
					//Get Relation Object
					oRelation = getLookupService().getLookupObject(rc.linkTO,listGetAt(deleteRElationList,i));
					//Remove Relation to parent
					evaluate("oLookup.remove#rc.linkAlias#(oRelation)");
				}
			}

			//Save Records
			getLookupService().save(oLookup);

			/* Relocate back to edit */
			setNextEvent(event="#instance.handlerPackage#lookups.dspEdit",queryString="lookup=#rc.lookup#&id=#rc.id###m2m_#rc.linkAlias#");		
		</cfscript>
	</cffunction>


<!----------------------------------- PRIVATE ------------------------------>
	
	<!--- Get/Set lookup Service --->
	<cffunction name="getLookupService" access="private" output="false" returntype="any" hint="Get LookupService">
		<cfreturn instance.LookupService/>
	</cffunction>	

	<cffunction name="fncLookupCheck" output="false" access="private" returntype="void" hint="Do a parameter check, else redirect">
		<cfargument name="event" type="any" required="true"/>
		<cfscript>
		if ( event.getTrimValue("lookup","") eq "")
			setNextEvent("#instance.handlerPackage#lookups");
		</cfscript>
	</cffunction>
	
	<!--- getFiles --->
	<cffunction name="getFiles" output="false" access="private" returntype="query" hint="Get a set of files">
		<cfargument name="dirPath" type="string" required="true" default="" hint="The directory Path"/>
		<cfargument name="filter" type="string" required="false" default="" hint="The default filter to apply"/>
		<cfset var qFiles = 0>
		
		<cfdirectory action="list" 
					 directory="#arguments.dirPath#"
					 name="qFiles"
					 filter="#arguments.filter#">
	
		<cfreturn qFiles>
	</cffunction>

	<!--- getSortedLookups --->
	<cffunction name="getSortedLookupKeys" output="false" access="private" returntype="any" hint="Get the sorted Lookups">
		<cfscript>
		var systemLookups = getSetting("lookups_tables");
		var systemLookupsKeys = ArrayNew(1);
		
		if( not isSimpleValue(systemLookups) ){
			systemLookupsKeys = structKeyArray(systemLookups);
			ArraySort(systemLookupsKeys,"text");
		}

		return systemLookupsKeys;
		</cfscript>
	</cffunction>

</cfcomponent>