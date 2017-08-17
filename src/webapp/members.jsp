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
        
        <sql:query var="mems" dataSource="jdbc/config-dev">
            select me.memidnum, me.firstname, me.lastname, hi.position, us.username, pm.activestatus, ii.institution, ro.projstartdate
            from
            um_member me join um_project_members pm on pm.memidnum=me.memidnum
            join um_member_username us on me.memidnum=us.memidnum
            join um_member_institution ii on ii.memidnum=me.memidnum and ii.current_inst='Y'
            join um_institutions tt on tt.institution = ii.institution
            join um_member_inst_history hi on hi.meminstidnum=ii.meminstidnum and hi.currentposition='Y'
            join um_projmem_history ro on ro.projmemidnum=pm.projmemidnum
            join profile_ug ug on ug.memidnum = me.memidnum
            where ug.group_id = 'lsst-desc-full-members' and pm.project=? 
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
            
           
        <a href="index.jsp">SWGs</a><br/>
        Publications Under Review<br/>
        Speakers Bureau<br/>
        <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/newCollaborator.jsp">New User Form</a>
        <p/>
        
       <display:table class="datatable" id="Rows" name="${mems.rows}" defaultsort="1">
           <display:column  title="Name" sortable="true"  headerClass="sortable">
              <a href="http://srs.slac.stanford.edu/GroupManager/exp/${appVariables.experiment}/protected/user.jsp?memidnum=${Rows.memidnum}&recType=INDB">${Rows.lastname}, ${Rows.firstname}</a>
           </display:column>
           
           <display:column  title="Username" sortable="true" headerClass="sortable">
                <a href="http://srs.slac.stanford.edu/GroupManager/exp/${appVariables.experiment}/protected/user.jsp?memidnum=${Rows.memidnum}&recType=INDB">${Rows.username}</a>
           </display:column>
                                        
           <display:column  property="activestatus" title="Active" sortable="true"  headerClass="sortable"/>
           <display:column  title="Builder" sortable="true"  headerClass="sortable">
               TBD
           </display:column>
           <display:column  title="Institution" sortable="true"  headerClass="sortable">
               ${Rows.institution}
           </display:column>
           <display:column  title="Position" sortable="true"  headerClass="sortable">
               ${Rows.position}
           </display:column>
           <display:column  title="Status" sortable="true"  headerClass="sortable">
           </display:column>
           <display:column  title="Admin" sortable="true"  headerClass="sortable">
           </display:column>
           <display:column  title="PB Admin" sortable="true"  headerClass="sortable">
           </display:column>
           <display:column  title="SB Admin" sortable="true"  headerClass="sortable">
           </display:column>
       </display:table>
            
             
    </body>
</html>
