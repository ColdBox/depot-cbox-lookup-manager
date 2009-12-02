<cfoutput>
<tr id="o2m_#rc.alias#">
	<td class="center">
		<a href="javascript:removeRow('o2m_#rc.alias#')" title="Remove Relationship"><img border="0" src="#getSetting('lookups_imgPath')#/bin_closed.png" alt="Remove" title="Remove Relationship" /></a>
	</td>
	<td>#rc.alias#
		<input type="hidden" name="#rc.currentTable#_o2m" id="#rc.currentTable#_o2m" value="#rc.alias#" />
	</td>
	<td>
		<!--- The listing of To Class Lists --->
		<select name="#rc.currentTable#_o2m_#rc.alias#_toClassChooser" id="#rc.currentTable#_o2m_#rc.alias#_toClassChooser"
				 onChange="populateO2M('#rc.currentTable#_o2m_#rc.alias#_toColumn','#rc.currentTable#_o2m_#rc.alias#_toClass',this.value)">
			<option value='null' checked="checked">Please select a Class</option>
			<cfloop list="#rc.tables#" index="selectTable">
				<cfif currentTable neq selectTable>
				<option value="#selectTable#,#rc.aliasMap[selectTable]#">#rc.aliasMap[selectTable]#</option>
				</cfif>
			</cfloop>
		</select>
		<input type="hidden" name="#rc.currentTable#_o2m_#rc.alias#_toClass" id="#rc.currentTable#_o2m_#rc.alias#_toClass" value="">
	</td>
	<td>
		<!--- This rc.table Column Listing: Columns From Current rc.table --->
		<select name="#rc.currentTable#_o2m_#rc.alias#_toColumn" id="#rc.currentTable#_o2m_#rc.alias#_toColumn">
			<option></option>
		</select>
	</td>
	<td align="center"><label><input type="checkbox" name="#rc.currentTable#_o2m_#rc.alias#_lazy"></label></td>			
	<td align="center"><label><input type="checkbox" name="#rc.currentTable#_o2m_#rc.alias#_proxied"></label></td>
</tr>
</cfoutput>