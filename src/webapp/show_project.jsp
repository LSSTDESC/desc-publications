<%-- 
    Document   : publications
    Created on : Jun 30, 2017, 10:30:01 AM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>

 <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <link rel="stylesheet" type="text/css" href="css/pubstyles.css">
      <title>LSST-DESC Project ${param.projid}</title>
</head>

<body>
    <%-- show_project allows edits by project leads only --%>
    <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>
    
    <tg:underConstruction/>

    <c:set var="projid" value="${param.projid}"/>
    <c:set var="swgid" value="${param.swgid}"/>
    <c:set var="memberPool" value="lsst-desc-full-members"/>
    <c:set var="groupname" value="project_leads_${projid}"/>
    <c:set var="returnURL" value="show_project.jsp?projid=${projid}&swgid=${swgid}"/>
     
    <sql:query var="pubs">
        select paperid, state, title, added, builder_eligible, keypub, pubtype from descpub_publication where project_id = ? order by added
        <sql:param value="${projid}"/>
    </sql:query>    
        
    <sql:query var="leads">
        select convener_group_name cgn from descpub_swg where id = ?
        <sql:param value="${swgid}"/>
    </sql:query> 
    <c:set var="leaders" value="${leads.rows[0].cgn}"/>
    
    <c:if test="${param.updateProj == 'done'}">
        <div style="color: #0000FF">
            Project updated
        </div>
    </c:if> 
            
    <tg:editProject projid="${projid}" swgid="${swgid}" returnURL="show_project.jsp?projid=${projid}&swgid=${swgid}"/> 
  
    <p/>
    <hr align="left" width="45%"/>
    
    <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,leads.rows[0].cgn) || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )}">
        <p id="pagelabel">Add or Remove Project Leads</p>
        <tg:groupMemberEditor groupname="${groupname}" returnURL="${returnURL}"/> 
        <hr align="left" width="45%"/>
    </c:if>
    
    <c:if test="${pubs.rowCount > 0}">
        <p id="pagelabel">List of Document Entries (Total: ${pubs.rowCount})</p>
        <display:table class="datatable" id="Rows" name="${pubs.rows}" defaultsort="1" >
            <display:column title="Document ID" sortable="true" headerClass="sortable">
              DESC-${Rows.paperid}
            </display:column>
            <display:column title="Document Title" sortable="true" headerClass="sortable" style="text-align:left;">
                <a href="show_pub.jsp?paperid=${Rows.paperid}&swgid=${swgid}">${Rows.title}</a>
            </display:column>
            <display:column property="pubtype" title="Type" sortable="true" headerClass="sortable" style="text-align:left;"/>
            <display:column property="state" title="State" sortable="true" headerClass="sortable"/>
            <display:column property="added" title="Created" sortable="true" headerClass="sortable"/> 
            <display:column title="Number of Versions" sortable="true" headerClass="sortable">
                <sql:query var="vers">
                    select count(*) tot from descpub_publication_versions where paperid = ?
                    <sql:param value="${Rows.paperid}"/>
                </sql:query>
                <a href="uploadPub.jsp?paperid=${Rows.paperid}">${vers.rows[0].tot}</a>
            </display:column>
            <display:column property="keypub" title="Key Pub" sortable="true" headerClass="sortable"/> 
        </display:table>  
        <p/> 
    </c:if>
    <p/>
 
    <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,leaders) || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )}">
                <hr align="left" width="45%"/> 
        <form action="addPublication.jsp">
            <input type="hidden" name="task" value="create_publication_form"/>
            <input type="hidden" name="swgid" value="${swgid}"/>
            <input type="hidden" name="projid" value="${projid}"/>
            <input type="submit" value="Create Document Entry"/>
        </form>
    </c:if>  
        
</body>
</html>
    
    
</html>

