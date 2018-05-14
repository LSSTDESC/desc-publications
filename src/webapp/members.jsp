<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="f" uri="http://lsstdesc.org/functions" %>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<!DOCTYPE html>

<html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <%--  <link rel="stylesheet" href="css/site-demos.css"> --%>
      <title>DESC Publication Board</title>
    </head>
    <body>
        
        <tg:underConstruction/>
        
       <sql:query var="mems">
            select me.memidnum, me.firstname, me.lastname, hi.position, us.username, pm.activestatus, ii.institution, ro.projstartdate
            from
            um_member me join um_project_members pm on pm.memidnum=me.memidnum
            join um_member_username us on me.memidnum=us.memidnum
            join um_member_institution ii on ii.memidnum=me.memidnum and ii.current_inst='Y'
            join um_institutions tt on tt.institution = ii.institution
            join um_member_inst_history hi on hi.meminstidnum=ii.meminstidnum and hi.currentposition='Y'
            join um_projmem_history ro on ro.projmemidnum=pm.projmemidnum
            join profile_ug ug on ug.memidnum = me.memidnum
            where ug.group_id = 'lsst-desc-full-members' and me.lastname != 'gpc1' and pm.project=? order by me.lastname
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
        
       <display:table class="datatable" id="Rows" name="${mems.rows}" defaultsort="1">
           <display:column  title="First Name" property="firstname" style="text-align:left;" sortable="true"  headerClass="sortable"/>
           <display:column  title="Last Name" property="lastname" style="text-align:left;" sortable="true"  headerClass="sortable"/>
                
           <display:column  title="Profile" style="text-align:left;" sortable="true"  headerClass="sortable">
              <a href="http://srs.slac.stanford.edu/GroupManager/exp/${appVariables.experiment}/protected/user.jsp?memidnum=${Rows.memidnum}&recType=INDB">${Rows.lastname}, ${Rows.firstname}</a>
           </display:column>     
           <display:column property="activestatus" title="Active" style="text-align:left;" sortable="true"  headerClass="sortable"/>
           <display:column  title="Builder" sortable="true"  headerClass="sortable">
               TBD
           </display:column>
           <display:column  title="Institution" property="institution" style="text-align:left;" sortable="true" headerClass="sortable"/>
               
           <display:column  title="Position" property="position" style="text-align:left;" sortable="true"  headerClass="sortable"/>
               
           <display:column  title="Admin" style="text-align:left;" sortable="true"  headerClass="sortable">
           </display:column>
           <display:column  title="PB Admin" style="text-align:left;" sortable="true"  headerClass="sortable">
           </display:column>
           <display:column  title="SB Admin" style="text-align:left;" sortable="true"  headerClass="sortable">
           </display:column>
       </display:table> 
    </body>
</html>
