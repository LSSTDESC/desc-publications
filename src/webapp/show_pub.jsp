<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/utils" prefix="utils"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/pubstyles.css">
    </head>
    <body>
        
        <tg:underConstruction/>
        
        <fmt:setTimeZone value="UTC"/>  
        <c:if test="${!empty msg}">
            <p id="pagelabel">${msg}</p> 
        </c:if>
         
        <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
            <c:redirect url="noPermission.jsp?errmsg=7"/>
        </c:if>
            
        <c:set var="paperGroup" value="paper_${param.paperid}"/>
        <%-- when testing against dev the tag gm:isUserInGroup won't work because it always checks against the prod db so test separately if user can edit paper.
        canEdit checks if conveners can edit, userCanEdit checks if user can edit
        --%>
        <c:set var="userCanEdit" value="false"/>
        <sql:query var="can">
          select count(*) tot from profile_ug where group_id=? and user_id=?
          <sql:param value="${paperGroup}"/>
          <sql:param value="${userName}"/>
        </sql:query>
        <c:if test="${can.rowCount > 0}">
          <c:set var="userCanEdit" value="true"/>
        </c:if>
        
        <sql:query var="pubs">
            select * from descpub_publication where paperid = ? 
            <sql:param value="${param.paperid}"/>
        </sql:query> 
            
        <c:set var="pubtype" value="${pubs.rows[0].pubtype}"/>
        <c:set var="projid" value="${pubs.rows[0].project_id}"/>
        <c:set var="canEdit" value="false"/>
        
        <%-- get the convener groupname --%>
        <sql:query var="leads">
           select  wg.id, wg.convener_group_name from descpub_project_swgs ps join descpub_swg wg on ps.swg_id = wg.id
           join descpub_publication dd on dd.project_id = ps.project_id where dd.paperid = ?
           <sql:param value="${param.paperid}"/>
        </sql:query>
           
        <%-- check if current user has r/w access --%>   
        <c:forEach var="x" items="${leads.rows}">
            <c:if test="${gm:isUserInGroup(pageContext,x.convener_group_name)}">
                <c:set var="canEdit" value="true"/>
            </c:if>
        </c:forEach>
        
        <%-- select the display fields appropriate for this pubtype --%>
        <sql:query var="fi">
            select pb.metaid, me.data, me.label, me.datatype, pb.multiplevalues, pb.formposition from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
            where pb.pubtype = ? order by pb.formposition
            <sql:param value="${pubtype}"/>
        </sql:query>
               
        <sql:query var="countpapers">
            select count(*) from descpub_publication where project_id = ?
            <sql:param value="${projid}"/>
        </sql:query>   
      
        <%-- check for versions --%>
        <sql:query var="vers">
            select paperid, version, tstamp, to_char(tstamp,'Mon-dd-yyyy') pst, remarks from descpub_publication_versions where paperid=? order by version desc
            <sql:param value="${param.paperid}"/>
        </sql:query>
            
        <h2>Document: <strong>DESC-${param.paperid}</strong></h2>
        <display:table class="datatable" id="pubs" name="${pubs.rows}">
            <display:column title="Document type">
                ${pubtype}
            </display:column>
            <display:column property="project_id" title="Project"/>
            <c:forEach var="x" items="${fi.rows}">
               <display:column title="${x.label}" property="${x.data}" sortable="true" headerClass="sortable" style="text-align:left;"/>
            </c:forEach>
             <c:if test="${pubs.can_request_authorship != 'N' && pubs.state != 'inactive'}">
               <display:column title="Request Authorship" href="requestAuthorship.jsp" paramId="paperid" property="paperid" paramProperty="paperid" sortable="true" headerClass="sortable" style="text-align:right;"/>
            </c:if>
            <c:if test="${(gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') ||  gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,paperGroup) || canEdit=='true' || userCanEdit=='true') && pubs.state != 'inactive'}">
                <display:column title="Edit" href="editLink.jsp">
                       <a href="editLink.jsp?paperid=${param.paperid}">DESC-${param.paperid}</a>
                </display:column>
            </c:if>
        </display:table>
        <p/>  
        
        <c:if test="${vers.rowCount > 0}">
            <display:table class="datatable" id="row" name="${vers.rows}">
                <display:column title="Versions of DESC-${row.paperid}" sortable="true" headerClass="sortable">
                    <a href="download?paperid=${row.paperid}&version=${row.version}">Download version ${row.version}</a>
                </display:column>
                <display:column title="Remarks" property="remarks"/>
                <display:column title="Uploaded (UTC)">
                   <fmt:formatDate value="${row.tstamp}" pattern="yyyy-MM-dd HH:mm:ss"/>
                </display:column>
            </display:table>
            <p/> 
        </c:if>
         
        <form action="upload.jsp" method="post" enctype="multipart/form-data">
            <div>
              <fieldset class="fieldset-auto-width">
                  <legend><strong>Upload</strong></legend><p/>
                  Upload new version of DESC-${param.paperid}<p/>
                  <input type="file" name="fileToUpload" id="fileToUpload"><p/>
                  Remarks: <input type="text" name="remarks" required><p/>
                  <input type="submit" value="Upload Document" name="submit">
                  <input type="hidden" name="forwardTo" value="/uploadPub.jsp?paperid=${param.paperid}" />
                  <input type="hidden" name="paperid" value="${param.paperid}"/>
              </fieldset>
            </div>
        </form>
            
    </body>
</html>