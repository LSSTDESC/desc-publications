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
    
    <tg:underConstruction/>

    <c:set var="projid" value="${param.projid}"/>
    <c:set var="swgid" value="${param.swgid}"/>
    <c:set var="wgname" value="${param.name}"/>
    <c:set var="memberPool" value="lsst-desc-full-members"/>
    <c:set var="groupname" value="project_leads_${projid}"/>
    <c:set var="returnURL" value="show_project.jsp?projid=${projid}&swgid=${swgid}"/>

            
    <sql:query var="pubs">
        select paperid, state, title, added, builder_eligible, keypub from descpub_publication where project_id = ? 
        order by title
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
    
    <p id="pagelabel">List of Document Entries</p>
    <display:table class="datatable" id="Rows" name="${pubs.rows}" defaultsort="1">
        <display:column title="Paper ID" sortable="true" headerClass="sortable">
            <a href="show_pub.jsp?paperid=${Rows.paperid}&projid=${projid}&swgid=${swgid}">${Rows.paperid}</a>
        </display:column>
        <display:column title="Document Title" sortable="true" headerClass="sortable">
            <a href="show_pub.jsp?paperid=${Rows.paperid}&swgid=${swgid}">${Rows.title}</a>
        </display:column>
        <display:column property="state" title="State" sortable="true" headerClass="sortable"/>
        <display:column property="added" title="Created" sortable="true" headerClass="sortable"/> 
        <display:column property="builder_eligible" title="Builder" sortable="true" headerClass="sortable"/>        
        <display:column property="keypub" title="Key Pub" sortable="true" headerClass="sortable"/>        
    </display:table>  
   
    <p/> 
     
    <hr align="left" width="45%"/> 
    
    <p/>
    
    <%--
    <a href="addPublication.jsp?projid=${projid}&swgid=${swgid}&name=${wgname}">Add Publication</a>  
    --%>
    
    <form action="addPublication.jsp">
        <input type="hidden" name="task" value="create_publication_form"/>
        <input type="hidden" name="swgid" value="${swgid}"/>
        <input type="hidden" name="projid" value="${projid}"/>
        <input type="submit" value="Create Document Entry"/>
    </form>
    
        
    <%--
    <a href="addDocument.jsp?projid=${projid}&swgid=${swgid}">Add Document</a>

    
    <tg:addPublication experiment="${appVariables.experiment}" projid="${projid}" swgid="${swgid}" returnURL="show_project.jsp?projid=${projid}&swgid=${swgid}"/>  
    
    <p/>
    <tg:addDocument swgid="${swgid}" userName="${userName}" experiment="${appVariables.experiment}" projid="${projid}" returnURL="show_project.jsp"/>  
   --%>
</body>
</html>
    
    
</html>

