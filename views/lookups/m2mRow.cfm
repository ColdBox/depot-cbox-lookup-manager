<cfoutput>
<tr id="m2m_#rc.alias#">
	<td class="center">
		<a href="javascript:removeRow('m2m_#rc.alias#')" title="Remove Relationship"><img border="0" src="#getSetting('lookups_imgPath')#/bin_closed.png" alt="Remove" title="Remove Relationship" /></a>
	</td>
	<td>#rc.alias#
		<input type="hidden" name="#rc.currentTable#_m2m" id="#rc.currentTable#_m2m" value="#rc.alias#" />
	</td>
	<td>
		<!--- M2M rc.currentTable Chooser: List of All rc.tables --->
		<select name="#rc.currentTable#_m2m_#rc.alias#_table" id="#rc.currentTable#_m2m_#rc.alias#_table" 
				onChange="populateColumns('#rc.currentTable#_m2m_#rc.alias#_fromColumn','#rc.currentTable#_m2m_#rc.alias#_toColumn',this.value)">
			<option value='null' checked="checked">Please select a table</option>
			<cfloop query="rc.qTables">
			<cfif rc.qTables.table_type eq "TABLE">
			<option>#table_name#</option>
			</cfif>
			</cfloop>
		</select>
	</td>
	<td>#rc.aliasMap[rc.currentTable]#</td>
	<td>
		<!--- This rc.table Column Listing: Columns From Current rc.table --->
		<select name="#rc.currentTable#_m2m_#rc.alias#_fromColumn" id="#rc.currentTable#_m2m_#rc.alias#_fromColumn">
			<option></option>
		</select>
	</td>
	<td>
		<!--- The listing of To Class Lists --->
		<select name="#rc.currentTable#_m2m_#rc.alias#_toClass" id="#rc.currentTable#_m2m_#rc.alias#_toClass">
			<cfloop list="#rc.tables#" index="selectTable">
				<option>#rc.aliasMap[selectTable]#</option>
			</cfloop>
		</select>
	</td>
	<td>
		<!--- To rc.table Column Listing --->
		<select name="#rc.currentTable#_m2m_#rc.alias#_toColumn" id="#rc.currentTable#_m2m_#rc.alias#_toColumn">
			<option></option>
		</select>
	</td>
</tr>
</cfoutput>