<cfoutput>
<!--- js --->
<cfsavecontent variable="js">
<cfoutput>
<script type="text/javascript">
	$(document).ready(function() {
	/* Form Validation */
		$('##manageForm').formValidation({
			err_class 	: "invalidLookupInput",
			err_list	: true,
			callback	: 'prepareSubmit'
		});
	});
	function submitForm(){
		$('##manageForm').submit();		
	}
	function prepareSubmit(){
		$('##_buttonbar').slideUp("fast");
		$('##_loader').fadeIn("slow");		
		return true;
	}
	function removeRow(id){
		$('##'+id).remove();
	}
	function addm2mRow(theAlias,theTable){
		var relAlias = $('##'+theAlias).val();
		
		if( relAlias.length == 0 ){
			alert('Please enter a name for the many to many relationship');
		}
		else{
			$('##'+theAlias).val('');
			//Submit Request
			$.post("#event.buildLink(rc.xehAddm2m)#",
				  { alias:relAlias,
				  	tables:'#rc.tables#',
				  	currentTable:theTable,
				  	aliasMap:'#rc.aliasMapJSON#'}, 
				  function(data){
					$("##"+theTable+"_m2m_body").append(data);
				  }
			);
		}
	}
	function addo2mRow(theAlias,theTable){
		var relAlias = $('##'+theAlias).val();
		
		if( relAlias.length == 0 ){
			alert('Please enter a name for the one to many relationship');
		}
		else{
			$('##'+theAlias).val('');
			//Submit Request
			$.post("#event.buildLink(rc.xehAddo2m)#",
				  { alias: relAlias,
				  	tables:'#rc.tables#',
				  	currentTable:theTable,
				  	aliasMap:'#rc.aliasMapJSON#'}, 
				  function(data){
					$("##"+theTable+"_o2m_body").append(data);
				  }
			);
		}
	}
	function populateColumns(from,to,table){
		if( table != 'null' ){
			$.getJSON("#event.buildLink(rc.xehTableColumns)#",
				  { targetTable:table }, 
				  function(response){
					var options = '';
					$.each(response.data['column_name'],function(idx,value){
						options += '<option>' + value + '</option>';
					})
				   	$("##"+from).html(options);	
				   	$("##"+to).html(options);
				  }
			);
		}
		else{
			$("##"+from).html('');	
			$("##"+to).html('');
		}
	}
	function populateO2M(to,toClass,tableWithAlias){
		if( tableWithAlias != 'null' ){
			var values = tableWithAlias.split(",");
			var table = values[0];
			var alias = values[1];
		
			$.getJSON("#event.buildLink(rc.xehTableColumns)#",
				  { targetTable:table }, 
				  function(response){
					var options = '';
					$.each(response.data['column_name'],function(idx,value){
						options += '<option>' + value + '</option>';
					})
				   	$("##"+to).html(options);
				   	$("##"+toClass).val(alias);
				  }
			);
		}
		else{
			$("##"+to).html('');
			$("##"+toClass).val('');
		}
	}
	function deactivate(prefix,col,value){
		thisPrefix = prefix + col;
		if( value ){
			$("##"+thisPrefix+"_linkName").removeAttr('disabled');
			$("##"+thisPrefix+"_lazy").removeAttr('disabled');
			$("##"+thisPrefix+"_proxied").removeAttr('disabled');
			$("##"+prefix+"parents").val('');
		}
		else{
			$("##"+thisPrefix+"_linkName").attr('disabled','disabled');
			$("##"+thisPrefix+"_lazy").attr('disabled','disabled');
			$("##"+thisPrefix+"_proxied").attr('disabled','disabled');
			$("##"+prefix+"parents").val(col);
		}
	}
</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#js#">
<div id="content">
<!--- Title --->
<h2><img src="#rc.imgPath#/cog.png" align="absmiddle"> Lookup Manager > Add Lookup Columns</h2>
<p>Many To Many and One To Many relationships will have to be done manually by updating the transfer.xml</p>

<!--- Render Messagebox. --->
#getPlugin("messagebox").renderit()#

<!--- New Lokups To Configure --->
<form name="manageForm" id="manageForm" action="#event.buildLink(rc.xehcreateLookups)#" method="post">
	<input type="hidden" name="tables" value="#rc.tables#">
	<input type="hidden" name="transferConfigPath" value="#rc.transferConfigPath#">
	
	<cfloop collection="#rc.lookupConfig#" item="table">
	<cfset thisTable = rc.lookupConfig[table]>
	<fieldset>
	<input type="hidden" name="#table#_cols" value="#valuelist(thisTable.columns.column_name)#">
	<legend>Table: #table#</legend>
	
	<label class="inlineLabel">Alias: </label> #thisTable.alias#<br />
	<input type="hidden" name="#table#_alias" value="#thisTable.alias#">
	
	<label class="inlineLabel">Transfer Class: </label> #thisTable.class#<br />
	<input type="hidden" name="#table#_class" value="#thisTable.class#">
	
	<label class="inlineLabel">Decorator: </label> model.#thisTable.decorator# <br />
	<input type="hidden" name="#table#_decorator" value="#thisTable.decorator#">
	
	<fieldset>
	<legend>General Object Setup</legend>
		<label class="inlineLabel">Primary Key Generate </label>
		<input type="radio" name="#table#_pkgenerate" checked="checked" value="true">Yes
		<input type="radio" name="#table#_pkgenerate" value="false">No
	</fieldset>
	
	<fieldset>
	<legend>#thisTable.class# Properties</legend>
	<table class="tablesorter" width="100%" id="setlookupsTable" cellspacing="1" cellpadding="0" border="0">
		<thead>
		<tr>
			<th>Column</th>
			<th>Alias</th>
			<th width="20">SortBy</th>
			<th width="20">Display</th>
			<th width="20">Nullable</th>		
			<th width="20">Ignore Insert</th>		
			<th width="20">Ignore Update</th>		
			<th width="20">Refresh Insert</th>		
			<th width="20">Refresh Update</th>		
			<th>DB Type</th>
			<th>CF Type</th>
			<th>Max Len</th>
			<th>HTML Control</th>
			<th>HelpText</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="thisTable.columns">
		<cfif not is_foreignkey>
		<tr>
			<!--- PRIMARY KEY OR COLUMN --->
			<td>
				<cfif IS_PRIMARYKEY>
					<strong>#column_name#</strong>
				<cfelse>
					#column_name#
				</cfif>
				<cfif IS_PRIMARYKEY><strong>(PK)</strong>
					<input type="hidden" name="#table#_pkcolumn" id="#table#_pkcolumn" value="#column_name#">
				<cfelse>
					<input type="hidden" name="#table#_col_#column_name#" id="#table#_col_#column_name#" value="#column_name#">
				</cfif>
			</td>
			
			<!--- ALIAS --->
			<td>
				<cfif is_primarykey>
					<input type="text" size="15" name="#table#_pkalias" id="#table#_pkalias" value="#column_name#">
				<cfelse>
					<input type="text" size="15" name="#table#_col_#column_name#_alias" id="#table#_col_#column_name#_alias" value="#column_name#">
				</cfif>
				
			</td>
			
			<!--- Sort By --->
			<td align="center"><label><input type="radio" <cfif IS_PRIMARYKEY>checked="true"</cfif> name="#table#_sortby" value="#column_name#"></label></td>
			
			<!--- DISPLAY --->
			<td align="center"><label><input type="checkbox" <cfif IS_PRIMARYKEY>disabled="true"<cfelse>checked="checked"</cfif>
											 name="#table#_col_#column_name#_display"></label></td>
			
			<!--- NULLABLE --->
			<td align="center"><label><input type="checkbox" <cfif is_nullable>checked="checked"<cfelse>disabled="true"</cfif> 
											 name="#table#_col_#column_name#_nullable"></label></td>
			
			<td align="center"><label><input type="checkbox" name="#table#_col_#column_name#_ignoreinsert" <cfif IS_PRIMARYKEY>disabled="true"</cfif>></label></td>			
			<td align="center"><label><input type="checkbox" name="#table#_col_#column_name#_ignoreupdate" <cfif IS_PRIMARYKEY>disabled="true"</cfif>></label></td>
			<td align="center"><label><input type="checkbox" name="#table#_col_#column_name#_refreshinsert" <cfif IS_PRIMARYKEY>disabled="true"</cfif>></label></td>			
			<td align="center"><label><input type="checkbox" name="#table#_col_#column_name#_refreshupdate" <cfif IS_PRIMARYKEY>disabled="true"</cfif></label></td>
			
			<td>#type_name#</td>
			
			<td>
				<cfif is_primarykey>
					<select name="#table#_pktype" id="#table#_pktype">
						<cfloop list="#rc.pktypes#" index="ptype">
						<option <cfif matchType(type_name) eq ptype>selected="selected"</cfif>>#ptype#</option>
						</cfloop>
					</select>
				<cfelse>
					<select name="#table#_col_#column_name#_type" id="#table#_col_#column_name#_type">
						<cfloop list="#rc.propertyTypes#" index="type">
						<option <cfif matchType(type_name) eq type>selected="selected"</cfif>>#type#</option>
						</cfloop>
					</select>	
				</cfif>
			</td>
			
			<td>
				<input type="text" size="5" name="#table#_col_#column_name#_maxlen" value="#COLUMN_SIZE#" 
					   <cfif column_size eq 0 OR is_primarykey>disabled="true" class="disabled"</cfif>>
			</td>
			
			<td>
			<cfif matchType(type_name) eq "boolean">
				<select name="#table#_col_#column_name#_html" id="#table#_col_#column_name#_html" <cfif matchType(type_name) eq "date">disabled="true" class="disabled"</cfif>>
					<cfloop list="#rc.lookupBooleanTypes#" index="lookuptype">
					<option <cfif lookuptype eq "text">selected="selected"</cfif>>#lookuptype#</option>
					</cfloop>
				</select>
			<cfelse>
				<select name="#table#_col_#column_name#_html" id="#table#_col_#column_name#_html" 
						<cfif matchType(type_name) eq "date">disabled="true" class="disabled"</cfif>
						<cfif IS_PRIMARYKEY>disabled="true"</cfif>
				>
					<cfloop list="#rc.lookupHTMLTypes#" index="lookuptype">
					<option <cfif lookuptype eq "text">selected="selected"</cfif>>#lookuptype#</option>
					</cfloop>
				</select>
			</cfif>			
			</td>
			<td>
				<input type="text" size="25" name="#table#_col_#column_name#_helptext" value=""
					   <cfif IS_PRIMARYKEY>disabled="true"</cfif>>
			</td>
		</tr>
		</cfif>
		</cfloop>
		</tbody>
	</table>
	</fieldset>
	
	<fieldset>
		<legend>#thisTable.class# Many To One OR Parent One To Many Relationships</legend>
		The following are the foreign key relationships found for this table.  If none where found, the table will be empty.
		If this will be a <strong>Parent One To Many</strong>, uncheck the <strong>Create M2O</strong> checkbox and fill out the <strong>Display Column</strong> box.
		<table class="tablesorter" width="100%" id="setlookupsTable" cellspacing="1" cellpadding="0" border="0">
		<thead>
		<tr>
			<th>Create M2O</th>
			<th>Column</th>
			<th>Referenced Table</th>
			<th>Referenced Key</th>
			<th>M2O Name</th>
			<th>M2O Link To Class Name</th>
			<th>Display Column</th>
			<th>Lazy</th>
			<th>Proxied</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="thisTable.columns">
		<cfif is_foreignkey>
			<cfset thisRelation = getFKColumns(REFERENCED_PRIMARYKEY_TABLE)>
			<input type="hidden" name="#table#_m2o_#column_name#_linktoColumn" value="#column_name#">
			<input type="hidden" name="#table#_m2o_all" value="#column_name#">
			<input type="hidden" name="#table#_m2o_parents" id="#table#_m2o_parents" value="">
			<tr>
				<td align="center">
					<input type="checkbox" name="#table#_m2o" value="#column_name#" checked="true" 
						   onClick="deactivate('#table#_m2o_','#column_name#',this.checked)">
				</td>
				<td>#column_name#</td>
				<td>#REFERENCED_PRIMARYKEY_TABLE#</td>
				<td>#REFERENCED_PRIMARYKEY#</td>
				<td><input type="text" name="#table#_m2o_#column_name#_linkName" id="#table#_m2o_#column_name#_linkName" value="" size="25" ></td>
				<td>
					<select name="#table#_m2o_#column_name#_linktoClass" id="#table#_m2o_#column_name#_linktoClass">
						<cfloop list="#rc.tables#" index="selectTable">
							<option>#rc.aliasMap[selectTable]#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<select name="#table#_m2o_#column_name#_displaycolumn" id="#table#_m2o_#column_name#_displaycolumn" required="true">
						<cfloop query="thisRelation">
							<option>#thisRelation.column_name#</option>
						</cfloop>
					</select>
				</td>
				<td align="center"><label><input type="checkbox" name="#table#_m2o_#column_name#_lazy" id="#table#_m2o_#column_name#_lazy"></label></td>			
				<td align="center"><label><input type="checkbox" name="#table#_m2o_#column_name#_proxied" id="#table#_m2o_#column_name#_proxied"></label></td>			
			</tr>
		</cfif>
		</cfloop>
		</tbody>
	</table>
	</fieldset>
	
	<!--- MANY TO MANY RELATIONSHIPS --->
	<fieldset>
		<legend>#thisTable.class# Many To Many Relationships</legend>
		If this table has many to many relationships, please add them below. If not, just skip this section.
		
		<label class="inlineLable">Relation Name: </label>
		<input type="text" name="#table#_m2m_adder" id="#table#_m2m_adder" value="" size="20">
		<input type="button" value="Add Many To Many" onClick="addm2mRow('#table#_m2m_adder','#table#')">
		
		<table class="tablesorter" width="100%" cellspacing="1" cellpadding="0" border="0">
		<thead>
		<tr>
			<th width="20"></th>
			<th>Relation Name</th>
			<th>Choose M2M Table</th>
			<th>From Class</th>
			<th>Choose From Column</th>
			<th>Choose To Class</th>
			<th>Choose To Column</th>
		</tr>
		</thead>
		<tbody id="#table#_m2m_body"></tbody>
	</table>
	</fieldset>
	
	<!--- ONE TO MANY RELATIONSHIPS --->
	<fieldset>
		<legend>#thisTable.class# One To Many Relationships</legend>
		If this table has one to many relationships, please add them below. If not, just skip this section.
		<label class="inlineLable">Relation Name: </label>
		<input type="text" name="#table#_o2m_adder" id="#table#_o2m_adder" value="" size="20">
		<input type="button" value="Add One To Many" onClick="addo2mRow('#table#_o2m_adder','#table#')">
		<table class="tablesorter" width="100%" cellspacing="1" cellpadding="0" border="0">
		<thead>
		<tr>
			<th width="20"></th>
			<th>Relation Name</th>
			<th>Link To Class</th>
			<th>Link To Column</th>
			<th>Lazy</th>
			<th>Proxied</th>
		</tr>
		</thead>
		<tbody id="#table#_o2m_body"></tbody>
	</table>
	</fieldset>
	
	</fieldset>
	
	<br /><hr /><br />
	</cfloop>
	
	<!--- Hidden Loader --->
	<div id="_loader" class="formloader">
		<p>
			Submitting...<br />
			<img src="#rc.imgPath#/ajax-loader-horizontal.gif" align="absmiddle">
			<img src="#rc.imgPath#/ajax-loader-horizontal.gif" align="absmiddle">
		</p>
	</div>
	
	<!--- Create / Cancel --->
	<div id="_buttonbar">
		<a href="#event.buildLink(rc.xehAdd,0)#" class="buttonLinks">
			<span>
				<img src="#rc.imgPath#/cancel.png" border="0" align="absmiddle" alt="Cancel" />
				Cancel
			</span>
		</a>
		&nbsp;
		<a href="javascript:submitForm()" class="buttonLinks">
			<span>
				<img src="#rc.imgPath#/add.png" border="0" align="absmiddle" alt="Add" />
				Create Lookups
			</span>
		</a>
	</div>
</form>
</div>
</cfoutput>
