<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	The lookups service layer
----------------------------------------------------------------------->
<cfcomponent name="LookupService" hint="This is the lookup service." output="false">

<!----------------------------------- CONSTRUCTOR ------------------------------>

	<cffunction name="init" returntype="LookupService" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="transfer" 	type="any" _wireme="ocm:Transfer">
		<cfargument name="transaction"  type="any" _wireme="ocm:TransferTransaction">
		<cfargument name="lookupsDSN"   type="any" _wireme="coldbox:datasource:lookups">
		<cfargument name="json"   		type="any" _wireme="coldbox:plugin:json">
		<!--- ************************************************************* --->
		<cfscript>
			variables.instance = StructNew();
	
			/* Setup Transactions */
			arguments.transaction.advise(this, "^save");
			arguments.transaction.advise(this, "^delete");
			
			/* Properties */
			instance.mdDictionary = structnew();
			instance.transfer = arguments.transfer;
			instance.lookupsDSN = arguments.lookupsDSN;
			instance.JSON = arguments.json;
			
			return this;
		</cfscript>
	</cffunction>

<!----------------------------------- PUBLIC ------------------------------>

	<!--- Get a table listing --->
	<cffunction name="getListing" access="public" returntype="query" output="false" hint="Get a Lookup's query listing.">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" type="string" required="true" hint="The qualified transfer class name for this lookup. e.g. lookups.settings ">
		<!--- ************************************************************* --->
		<cfscript>
		//get lookup listing
		return instance.transfer.list(arguments.lookupClass, getDictionary(arguments.lookupClass).sortBy);
		</cfscript>
	</cffunction>

	<!--- Get's the lookups Transfer Object --->
	<cffunction name="getLookupMetaData" access="public" returntype="any" output="false" hint="Get a lookup's TO Metadata Object">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" type="string" required="true" hint="The qualified transfer class name for this lookup. e.g. lookups.settings ">
		<!--- ************************************************************* --->
		<cfscript>
		//get lookup listing
		return instance.transfer.getTransferMetaData(arguments.lookupClass);
		</cfscript>
	</cffunction>
	
	<cffunction name="getJointListing" access="public" returntype="query" output="false" hint="Get a Lookup's joint query listing.">
		<!--- ************************************************************* --->
		<cfargument name="fromClass" 	type="string" required="true" >
		<cfargument name="toClass"  	type="string" required="true" >
		<cfargument name="id"  			type="any" required="true" >
		<!--- ************************************************************* --->
		<cfscript>
		var fromMD = getDictionary(arguments.fromClass);
		var query = instance.transfer.createQuery("from #arguments.fromClass# 
												   join #arguments.toClass# 
												   where #arguments.fromClass#.#fromMD.PK# = :pk");
		query.setParam("pk",arguments.id);
		return instance.transfer.listByQuery(query);
		</cfscript>
	</cffunction>

	<!--- Get's the lookups Transfer Object --->
	<cffunction name="getLookupObject" access="public" returntype="any" output="false" hint="Get a new or set TO of the Lookup">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass"   type="string" required="true">
		<cfargument name="lookupID" type="string" required="false" default="">
		<!--- ************************************************************* --->
		<cfscript>
		var oLookup = "";

		//Get by ID or new
		if ( len(trim(arguments.lookupID)) eq 0){
			oLookup = instance.transfer.new(arguments.lookupClass);
		}
		else{
			oLookup = instance.transfer.get(arguments.lookupClass, arguments.lookupID);
		}
		/* return lookup object */
		return oLookup;
		</cfscript>
	</cffunction>

	<!--- Get a lookup by a property struct --->
	<cffunction name="getLookupByPropertyStruct" access="public" returntype="any" output="false" hint="Get a lookup object using a property structure.">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass"   		type="string" required="true">
		<cfargument name="propertyStruct" 	type="struct" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var oLookup = "";
		
		//Get by Property Struct
		oLookup = instance.transfer.readByPropertyMap(arguments.lookupClass, arguments.propertyStruct);

		return oLookup;
		</cfscript>
	</cffunction>

	<!--- Delete Listing --->
	<cffunction name="delete" access="public" returntype="void" output="false" hint="Hard Delete a lookup object">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" 	type="string" required="false" default="">
		<cfargument name="id"     		type="string" required="false" default="">
		<cfargument name="lookupObject" required="false" type="any" hint="You can send the lookup object to delete. MUTEX with lookupClass and id.">
		<!--- ************************************************************* --->
		<cfscript>
			var oLookup = "";
			
			/* Deleting with TO? */
			if( structKeyExists(arguments,"lookupObject") ){
				oLookup = arguments.lookupObject;
			}
			else{
				oLookup = instance.transfer.get(arguments.lookupClass,arguments.id);
			}
			//Remove Entry
			instance.transfer.delete(oLookup);
		</cfscript>
	</cffunction>
	
	<!--- Save the Lookup Object --->
	<cffunction name="save" hint="Saves a lookup object" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="LookupObject" hint="The Lookup object" type="any" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			instance.transfer.save(arguments.LookupObject);
		</cfscript>
	</cffunction>

	<!--- Get MD Dcitionary for a TO Class --->
	<cffunction name="getDictionary" access="public" returntype="struct" hint="Get a TO Metadata Dictionary entry" output="false">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" 	type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			var lookupDictionary = structnew();
			
			if ( not structKeyExists( instance.mdDictionary , arguments.lookupClass) ){
				//dictionary not found, prepare it
				lookupDictionary = prepareDictionary(arguments.lookupClass);
			}
			else
				lookupDictionary = structFind(instance.mdDictionary, arguments.lookupClass );
				
			return lookupDictionary;
		</cfscript>
	</cffunction>

	<!--- Prepare MD Dictionary for TO Class --->
	<cffunction name="prepareDictionary" access="public" returntype="struct" hint="Prepare a TO Metadata Dictionary" output="false">
		<!--- ************************************************************* --->
		<cfargument name="lookupClass" 	type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var oTO = "";
		var oTOMD = "";
		var mdStruct = structNew();
		var propIterator = "";
		var oProperty = "";
		var prop = structnew();
		var relIterator = "";
		var oRelation = "";
		var oPK = "";
		var rel = structnew();
		var oRelMD = "";
		var tmpTO = "";
		var tableConfig = structnew();

		//check if Dictionary set for this lookup, else end.
		if ( not structKeyExists(instance.mdDictionary,arguments.lookupClass) ){
			//Get lookup TO
			oTO = getLookupObject(arguments.lookupClass);
			//Get lookup TO MetaData Object
			oTOMD = getLookupMetaData(arguments.lookupClass);
			//Primary Key Object
			oPK = oTOMD.getPrimaryKey();
			//Table Config From Decorator if it exists
			if( structKeyExists(oTo,"getTableConfig") ){
				tableConfig = oTO.getTableConfig();
			}
			else{
				tableConfig = structnew();
			}
			//Get Lookup MD structure
			mdStruct.PK = oPK.getName();
			mdStruct.PKColumn = oPK.getColumn();
			if( structKeyExists(tableConfig,"sortBy") ){
				mdStruct.sortBy = tableConfig.sortBy;
			}
			else{
				mdStruct.sortBy = mdStruct.PK;
			}
			mdStruct.FieldsArray = ArrayNew(1);
			//Relations MD
			mdStruct.hasManyToOne = oTOMD.hasManyToOne();
			mdStruct.ManyToOneArray = ArrayNew(1);
			mdStruct.hasManyToMany = oTOMD.hasManyToMany();
			mdStruct.ManyToManyArray = ArrayNew(1);
			mdStruct.hasOneToMany = oTOMD.hasOneToMany();
			mdStruct.OneToManyArray = ArrayNew(1);
			/* Parent Relationships */
			mdStruct.hasParentOneToMany = oTOMD.hasParentOneToMany();
			mdStruct.ParentOneToManyArray = ArrayNew(1);
			
			//Primary Key Field
			prop = structnew();
			prop.alias = oPK.getName();
			prop.column = oPK.getColumn();
			prop.datatype = oPK.getType();
			prop.nullable = oPK.getIsNullable();
			//Display Property for PK
			if ( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"display") )
				prop.display = tableConfig[prop.alias].display;
			else
				prop.display = true;
			prop.html = "text";
			prop.ignoreInsert = false;
			prop.ignoreUpdate = false;
			prop.primaryKey = true;
			
			/* Add the PK to the fields array */
			ArrayAppend(mdStruct.FieldsArray,prop);

			//Get Properties
			propIterator = oTOMD.getPropertyIterator();
			while ( propIterator.hasNext() ){
				oProperty = propIterator.next();
				prop = structnew();
				prop.alias = oProperty.getName();
				prop.column = oProperty.getColumn();
				prop.datatype = oProperty.getType();
				prop.nullable = oProperty.getIsNullable();
				prop.ignoreInsert = oProperty.getIgnoreInsert();
				prop.ignoreUpdate = oProperty.getIgnoreUpdate();
				prop.primaryKey = false;

				//List Display MD
				if ( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"display") ){
					prop.display = tableConfig[prop.alias].display;
				}
				else{
					prop.display = true;
				}
				//HTML Type MD
				if ( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"html") ){
					prop.html = tableConfig[prop.alias].html;
				}
				else{
					prop.html = "text";
				}
				//Help TEXT
				if( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"helptext") ){
					prop.helptext = tableConfig[prop.alias].helptext;
				}
				else{
					prop.helptext = '';
				}
				if( structKeyExists(tableConfig,prop.alias) and structKeyExists(tableConfig[prop.alias],"validate") ){
					prop.validate = tableConfig[prop.alias].validate;
				}
				else{
					prop.validate = '';
				}
				
				//Atach Property
				ArrayAppend(mdStruct.FieldsArray,prop);
			}

			//Get Relations : Many To One
			relIterator = oTOMD.getManyToOneIterator();
			while ( relIterator.hasNext() ){
				oRelation = relIterator.next();
				rel = structnew();
				rel.alias = oRelation.getName();
				rel.column = oRelation.getLink().getColumn();
				rel.className = oRelation.getLink().getTO();
				
				/* Display column comes from the tableconfig */
				if( structKeyExists(tableConfig,rel.alias) and structKeyExists(tableConfig[rel.alias],"displayColumn") ){
					rel.DisplayColumn = tableConfig[rel.alias].DisplayColumn;
				}
				else{
					throw(message="The display column for the relation: #rel.alias# was not found in the table config.",
						  detail="This method is needed for many to one relations. Please check your code.",
						  type="LookupService.missingDisplayColumn");
				}
				
				//Get Relation MD
				oRelMD = getLookupMetaData(rel.className);
				rel.PK = oRelMD.getPrimaryKey().getName();
				rel.PKColumn = oRelMD.getPrimaryKey().getColumn();

				//Attach Relation
				ArrayAppend(mdStruct.ManyToOneArray,rel);
			}
			
			/* Parent One To Many */
			relIterator = oTOMD.getParentOneToManyIterator();
			while ( relIterator.hasNext() ){
				oRelation = relIterator.next();
				rel = structnew();
				rel.className = oRelation.getLink().getTO();
				rel.alias = rel.className;
				/* Display column comes from the tableconfig */
				if( structKeyExists(tableConfig,rel.alias) and structKeyExists(tableConfig[rel.alias],"displayColumn") ){
					rel.DisplayColumn = tableConfig[rel.alias].DisplayColumn;
				}
				else{
					throw(message="The display column for the relation: #rel.alias# was not found in the table config for #arguments.lookupClass#",
						  detail="This variable is needed for parent one to many relations. Please check your decorator code.",
						  type="LookupService.missingDisplayColumn");
				}
				
				//Get Relation MD
				oRelMD = getLookupMetaData(rel.className);
				rel.PK = oRelMD.getPrimaryKey().getName();
				rel.PKColumn = oRelMD.getPrimaryKey().getColumn();

				//Attach Relation
				ArrayAppend(mdStruct.ParentOneToManyArray,rel);
			}

			//Get Relations Many To Many
			relIterator = oTOMD.getManyToManyIterator();
			while ( relIterator.hasNext() ){
				oRelation = relIterator.next();
				rel = structnew();
				rel.alias = oRelation.getName();
				rel.linktable = oRelation.getTable();
				//From
				rel.linkFromColumn = oRelation.getLinkFrom().getColumn();
				rel.linkFromTO = oRelation.getLinkFrom().getTO();
				//To
				rel.linkToColumn = oRelation.getLinkTo().getColumn();
				rel.linkToTO = oRelation.getLinkTo().getTO();
				//Get tmp TO
				oRelMD = getDictionary(rel.linkToTO);
				//Setup DIsplay
				rel.linkToPK = oRelMD.PK;
				rel.linkToSortBy = oRelMD.SortBy;
				//CollectionType
				rel.collectionType = oRelation.getCollection().getType();
				//Attach Relation
				ArrayAppend(mdStruct.ManyToManyArray,rel);
			}
			
			/* Get Relations One To Many */
			relIterator = oTOMD.getOneToManyIterator();
			while ( relIterator.hasNext() ){
				oRelation = relIterator.next();
				rel = structnew();
				rel.alias = oRelation.getName();
				//To
				rel.linkToColumn = oRelation.getLink().getColumn();
				rel.linkToClass = oRelation.getLink().getTO();
				//Attach Relation
				ArrayAppend(mdStruct.OneToManyArray,rel);
			}

			//Attach to Dictionary
			StructInsert(instance.mdDictionary,arguments.lookupClass, mdStruct);
			
		}// end for if dictionary found
		else{
			/* Else just get the dictionary locally. */
			mdStruct = structFind(instance.mdDictionary, arguments.lookupClass );
		}
		return mdStruct;
		</cfscript>
	</cffunction>
	
	<!--- Clean Dictionary --->
	<cffunction name="cleanDictionary" access="public" returntype="void" output="false" hint="Clean the Metadata Dictionary">
		<cfset instance.mdDictionary = structnew()>
	</cffunction>

	<!--- getDBTables --->
	<cffunction name="getDBTables" output="false" access="public" returntype="any" hint="Get a datasources DB tables">
		<cfset var qTables = 0>

		<cfdbinfo datasource="#instance.lookupsDSN.getName()#" name="qTables" type="tables" />

		<cfreturn qTables>
	</cffunction>
	
	<!--- getDBColumns --->
	<cffunction name="getDBColumns" output="false" access="public" returntype="any" hint="Get a table's columns">
		<!--- ************************************************************* --->
		<cfargument name="table" 		type="string" required="true" hint="A table to retrieve"/>
		<!--- ************************************************************* --->
		<cfset var qCols = 0>

		<cfdbinfo datasource="#instance.lookupsDSN.getName()#" name="qCols" table="#arguments.table#" type="columns" />

		<cfreturn qCols>
	</cffunction>
	
	<!--- getDBTableConfigurations --->
	<cffunction name="getDBTableConfigurations" output="false" access="public" returntype="any" hint="Returns a struct of table configurations according to passed in tables and collected data from the lookup views">
		<!--- ************************************************************* --->
		<cfargument name="tables" 		type="string" required="true" hint="A comma delimmited list of tables to create configurations for"/>
		<cfargument name="collection" 	type="struct" required="true" hint="A collection of data to process"/>
		<!--- ************************************************************* --->
		<cfset var lookupConfig = structnew()>
		<cfset var table = 0>
		<cfset var tableConfig = 0>
		
		<cfloop list="#arguments.tables#" index="table">
			<!--- Prepare table config --->
			<cfset tableConfig = structnew()>
			<cfset tableConfig.alias = arguments.collection["#table#_alias"]>
			<cfset tableConfig.class = arguments.collection["#table#_class"]>
			<cfset tableConfig.decorator = arguments.collection["#table#_decorator"]>
			
			<!--- Get Column Info --->
			<cfdbinfo datasource="#instance.lookupsDSN.getName()#" name="tableConfig.columns" table="#table#" type="columns" />
			
			<!--- Save it in return configuration --->
			<cfset lookupConfig[table] = tableConfig>
		</cfloop>
		
		<cfreturn lookupConfig>
	</cffunction>
	
	<!--- createLookups --->
	<cffunction name="createLookups" output="false" access="public" returntype="any" hint="Create Lookups">
		<!--- ************************************************************* --->
		<cfargument name="tables" 		type="string" required="true" hint="The tables to create lookup config for"/>
		<cfargument name="collection" 	type="struct" required="true" default="" hint="The data collection to use to build the lookups"/>
		<!--- ************************************************************* --->
		<cfscript>
			var x = 0;
			var y = 0;
			var rc = arguments.collection;
			var lookupsPath = getDirectoryFromPath(getMetadata(this).path);
			/* Read IN ColdBox File */
			var coldboxXMLDoc  = xmlParse(rc.ConfigFileLocation);
			var lookupsSetting = xmlSearch(coldboxXMLDoc,"//YourSettings/Setting[@name='lookups_tables']");
			/* Transfer XML */
			var transferXMLDoc =  xmlParse(rc.transferConfigPath);
			var definitionsArray = xmlSearch(transferXMLDoc,"//objectDefinitions");
			var objDefinitions = definitionsArray[1].xmlChildren;
			var defIndex = 0;
			var objDelList = ArrayNew(1);
			/* Common Vars */
			var thisTable = "";
			var thisColumns = "";
			var thisCol = "";
			var thisColAlias = "";
			var objIndex = 1;
			var thisM2One = "";
			var thisM2OneAll = "";
			var thisM2M = "";
			var thisO2M = "";
			var thisRel = "";
			var thisRelAlias = "";
			var lookupsTables = {};
			var thisbuffer = 0;
			var tabAlign = "#chr(9)##chr(9)##chr(9)#";
			var cr = chr(13);
			var sortBy = "";
			var decoratorTemplate = ""; 
			
			/* Create Table JSON */
			for(x=1;x lte listLen(arguments.tables); x++){
				lookupsTables[rc["#listGetAt(arguments.tables,x)#_alias"]] = rc["#listGetAt(arguments.tables,x)#_class"];
			}
			/* Get the Original Struct */
			if( len(lookupsSetting[1].xmlAttributes.value) ){
				originalJSON = instance.json.decode(lookupsSetting[1].xmlAttributes.value);
			}
			else{ originalJSON = structnew(); }
			/* Merge */
			structAppend(originalJSON,lookupsTables,true);
			/* Create as JSON */
			originalJSON = replace(instance.json.encode(originalJSON),'"',"'","all");
			/* Set it back in the lookupXML */
			lookupsSetting[1].xmlAttributes.value = originalJSON;
			/* Write it out */
			FileWrite(rc.ConfigFileLocation,toString(coldboxXMLDoc));
			
			/* Cleanup of transfer.xml, for the same tables */
			for(x=1;x lte arrayLen(objDefinitions); x++){
				if( structKeyExists(objDefinitions[x].XMLAttributes,"table") AND
					listFindNoCase(arguments.tables,objDefinitions[x].XMLAttributes.table) ){
					arrayDeleteAt(objDefinitions,x);
					x--;
				}
			}
			/* Set new Index */
			defIndex = ArrayLen(objDefinitions) + 1;
			
			/* Loop over tables To add Transfer Stuff*/
			for(x=1;x lte listLen(arguments.tables); x++){
				/* Setup Loopers & Vars */
				objIndex = 1;
				thisTable = listGetAt(arguments.tables,x);
				thisColumns = rc["#thisTable#_cols"];
				thisM2One = "";
				thisM2OneParents = "";
				thisM2OneAll = "";
				thisM2M = "";
				thisO2M = "";
				/* Init M2One List */
				if( structKeyExists(rc,"#thisTable#_m2o") ){
					thisM2One = rc["#thisTable#_m2o"];
				}
				if( structKeyExists(rc,"#thisTable#_m2o_all") ){
					thisM2OneAll = rc["#thisTable#_m2o_all"];
				}
				if( structKeyExists(rc,"#thisTable#_m2o_parents") ){
					thisM2OneParents = rc["#thisTable#_m2o_parents"];
				}
				/* Init M2M List */
				if( structKeyExists(rc,"#thisTable#_m2m") ){
					thisM2M = rc["#thisTable#_m2m"];
				}
				/* Init O2M List */
				if( structKeyExists(rc,"#thisTable#_o2m") ){
					thisO2M = rc["#thisTable#_o2m"];
				}
				
				thisBuffer = createObject("java","java.lang.StringBuffer").init('');
				sortBy = rc["#thisTable#_sortby"];
				
				/* Create new Object */
				objDefinitions[defIndex] = xmlElemNew(transferXMLDoc,"object");
				/* Add attributes to new Object Definition */
				objDefinitions[defIndex].xmlAttributes["name"] = rc["#thisTable#_class"];
				objDefinitions[defIndex].xmlAttributes["table"] = thisTable;
				objDefinitions[defIndex].xmlAttributes["decorator"] = rc.AppMapping & ".model." & rc["#thisTable#_decorator"];
				/* Create Decorator Sort By */
				if( sortBy neq rc["#thisTable#_pkcolumn"] ){
					thisBuffer.append('#tabAlign#tc.SortBy = "'&rc["#thisTable#_col_#sortBy#_alias"]&'";#cr#');
				}
				
				/* Create PK Entry */
				objDefinitions[defIndex].xmlChildren[objIndex] = xmlElemNew(transferXMLDoc,"id");
				objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["name"] = rc["#thisTable#_pkalias"];
				objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["column"] = rc["#thisTable#_pkcolumn"];
				objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["type"] = rc["#thisTable#_pktype"];
				objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["generate"] = rc["#thisTable#_pkgenerate"];
				
				/* Create Columns */
				for(y=1; y lte listLen(thisColumns); y++){
					/* Setup Column and Looper */
					thisCol = listGetAt(thisColumns,y);
					if( thisCol neq rc["#thisTable#_pkcolumn"] AND 
						listFindNoCase(thisM2One,thisCol) eq 0 AND
						listFindNoCase(thisM2OneAll,thisCol) eq 0 ){
						objIndex++;
						thisColAlias = rc["#thisTable#_col_#thisCol#_alias"];
						/* Create Column Definition */
						objDefinitions[defIndex].xmlChildren[objIndex] = xmlElemNew(transferXMLDoc,"property");
						objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["name"] = rc["#thisTable#_col_#thisCol#_alias"];
						objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["column"] = thisCol;
						objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["type"] = rc["#thisTable#_col_#thisCol#_type"];
						/* Null Check */
						if( structKeyExists(rc,"#thisTable#_col_#thisCol#_nullable") ){
							objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["nullable"] = "true";
						}
						/* ignores */
						if( structKeyExists(rc,"#thisTable#_col_#thisCol#_ignoreinsert") ){
							objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["ignore-insert"] = "true";
						}
						if( structKeyExists(rc,"#thisTable#_col_#thisCol#_ignoreupdate") ){
							objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["ignore-update"] = "true";
						}
						/* refreshes */
						if( structKeyExists(rc,"#thisTable#_col_#thisCol#_refreshinsert") ){
							objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["refresh-insert"] = "true";
						}
						if( structKeyExists(rc,"#thisTable#_col_#thisCol#_refreshupdate") ){
							objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["refresh-update"] = "true";
						}
						/* Decorator Writes */
						thisBuffer.append('#tabAlign#tc.#thisColAlias#.helptext = "' & rc["#thisTable#_col_#thisCol#_helptext"] & '";#cr#');
						if( structKeyExists(rc,"#thisTable#_col_#thisColAlias#_maxlen") and rc["#thisTable#_col_#thisCol#_maxlen"] neq 0 ){
							thisBuffer.append('#tabAlign#tc.#thisColAlias#.maxlength = "' & rc["#thisTable#_col_#thisCol#_maxlen"] & '";#cr#');
						}
						if( not structKeyExists(rc,"#thisTable#_col_#thisCol#_display") ){
							thisBuffer.append('#tabAlign#tc.#thisColAlias#.display = false;#cr#');
						}
						if( structKeyExists(rc,"#thisTable#_col_#thisCol#_html") ){
							thisBuffer.append('#tabAlign#tc.#thisColAlias#.html = "' & rc["#thisTable#_col_#thisCol#_html"] & '";#cr#');
						}
					}//if not pK column					
				}
				/* Create Many To One Relationships */
				for(y=1; y lte listLen(thisM2One); y++){
					thisRel = listGetAt(thisM2One,y);
					objIndex++;
					/* Create ManyToOne Definition */
					objDefinitions[defIndex].xmlChildren[objIndex] = xmlElemNew(transferXMLDoc,"manytoone");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["name"] = rc["#thisTable#_m2o_#thisRel#_linkName"];
					/* Create Lazy */
					if( structKeyExists(rc,"#thisTable#_m2o_#thisRel#_lazy") ){
						objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["lazy"] = "true";
					}
					/* Create Proxied */
					if( structKeyExists(rc,"#thisTable#_m2o_#thisRel#_proxied") ){
						objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["proxied"] = "true";
					}
					/* Create Link Object */
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1] = xmlElemNew(transferXMLDoc,"link");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1].XMLAttributes["column"] = rc["#thisTable#_m2o_#thisRel#_linkToColumn"];
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1].XMLAttributes["to"] = rc["#thisTable#_m2o_#thisRel#_linkToClass"];	
					/* Create Decorator Writes */				
					thisRelAlias = rc["#thisTable#_m2o_#thisRel#_linkName"];
					thisBuffer.append('#tabAlign#tc.#thisRelAlias#.displayColumn = "' & rc["#thisTable#_m2o_#thisRel#_displayColumn"] & '";#cr#');
				}
				/* Create Decorator Parent ONe To Manys */
				for(y=1; y lte listLen(thisM2OneParents); y++){
					thisRel = listGetAt(thisM2OneParents,y);
					/* Create Decorator Writes */				
					thisRelAlias = rc["#thisTable#_m2o_#thisRel#_linktoClass"];
					thisBuffer.append('#tabAlign#tc.#thisRelAlias#.displayColumn = "' & rc["#thisTable#_m2o_#thisRel#_displayColumn"] & '";#cr#');
				}
				/* Create Many To Many Relationships */
				for(y=1; y lte listLen(thisM2M); y++){
					thisRel = listGetAt(thisM2M,y);
					objIndex++;
					/* Create Many To Many Definition */
					objDefinitions[defIndex].xmlChildren[objIndex] = xmlElemNew(transferXMLDoc,"manytomany");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["name"] = thisRel;
					objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["table"] = rc["#thisTable#_m2m_#thisRel#_table"];
					/* Create Link FROM Object */
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1] = xmlElemNew(transferXMLDoc,"link");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1].XMLAttributes["column"] = rc["#thisTable#_m2m_#thisRel#_fromColumn"];
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1].XMLAttributes["to"] = rc["#thisTable#_class"];	
					/* Create Link TO Object */
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[2] = xmlElemNew(transferXMLDoc,"link");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[2].XMLAttributes["column"] = rc["#thisTable#_m2m_#thisRel#_toColumn"];
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[2].XMLAttributes["to"] = rc["#thisTable#_m2m_#thisRel#_toClass"];
					/* Create Collection */
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[3] = xmlElemNew(transferXMLDoc,"collection");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[3].XMLAttributes["type"] = "array";
				}
				/* Create One To Many Relationships */
				for(y=1; y lte listLen(thisO2M); y++){
					thisRel = listGetAt(thisO2M,y);
					objIndex++;
					/* Create Many To Many Definition */
					objDefinitions[defIndex].xmlChildren[objIndex] = xmlElemNew(transferXMLDoc,"onetomany");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["name"] = thisRel;
					/* Create Lazy */
					if( structKeyExists(rc,"#thisTable#_o2m_#thisRel#_lazy") ){
						objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["lazy"] = "true";
					}
					/* Create Proxied */
					if( structKeyExists(rc,"#thisTable#_o2m_#thisRel#_proxied") ){
						objDefinitions[defIndex].xmlChildren[objIndex].XMLAttributes["proxied"] = "true";
					}
					/* Create Link TO Object */
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1] = xmlElemNew(transferXMLDoc,"link");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1].XMLAttributes["column"] = rc["#thisTable#_o2m_#thisRel#_toColumn"];
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[1].XMLAttributes["to"] = rc["#thisTable#_o2m_#thisRel#_toClass"];	
					/* Create Collection */
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[2] = xmlElemNew(transferXMLDoc,"collection");
					objDefinitions[defIndex].xmlChildren[objIndex].XMLChildren[2].XMLAttributes["type"] = "array";
				}
				
				/* Create Decorator */
				decoratorTemplate = FileRead(lookupsPath & "DecoratorTemplate.cfm");
				/* Replace TC Setup */
				decoratorTemplate = replacenocase(decoratorTemplate,"@tcreplace@",thisBuffer.toString());
				FileWrite(rc.modelsPath & "/" & replace(rc["#thisTable#_decorator"],".","/","all") & ".cfc", decoratorTemplate);
				/* Continue to new definition */
				defIndex++;
			}//end looping of table definitions
			/* Write the transfer.xml out */
			FileWrite(rc.transferConfigPath,xmlTransform(toString(transferXMLDoc),FileRead(lookupsPath & "xmlFormatter.xsl")));			
		</cfscript>
	</cffunction>
	
<!----------------------------------- PRIVATE ------------------------------>
	
	<!--- Throw Facade --->
	<cffunction name="throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<!--- Dump facade --->
	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	
	<!--- Rethrow Facade --->
	<cffunction name="rethrowit" access="private" returntype="void" hint="Rethrow facade" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The cfcatch object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
	
	<!--- Abort Facade --->
	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>

</cfcomponent>