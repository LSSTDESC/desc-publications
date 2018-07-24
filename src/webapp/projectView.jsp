<%-- 
    Document   : projectView
    Created on : Apr 11, 2018, 1:51:43 PM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/utils" prefix="utils"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>
 
<html>
 <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <link rel="stylesheet" type="text/css" href="css/pubstyles.css">
      <title>LSST-DESC Project ${param.projid}</title>
</head>

<c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
     <c:redirect url="noPermission.jsp?errmsg=7"/>
</c:if>
    
<tg:underConstruction/>

<%-- get all the papers under this project --%>
 <sql:query var="docs">
    select paperid, title, to_char(createdate,'YYYY-Mon-DD HH:MI:SS') createdate, pubtype from descpub_publication where project_id = ?
    <sql:param value="${param.projid}"/>
</sql:query> 
    
<c:set var="projectLeadGrpName" value="project_leads_${param.projid}"/>
<c:set var="projectGrpName" value="project_${param.projid}"/>

<%-- find the project leads --%>
<c:set var="projectLeaders" value=""/>
<sql:query var="leads">
    select u.first_name, u.last_name, u.memidnum, u.user_name from profile_user u join profile_ug ug on u.memidnum = ug.memidnum and u.experiment = ug.experiment
    where ug.group_id = ? and ug.experiment = ? order by u.last_name
    <sql:param value="${projectLeadGrpName}"/>
    <sql:param value="${appVariables.experiment}"/>
</sql:query>
<c:forEach var="line" items="${leads.rows}">
    <c:choose>
       <c:when test="${empty projectLeaders}">
           <c:set var="projectLeaders" value="${line.first_name} ${line.last_name}"/>
       </c:when>
       <c:when test="${!empty projectLeaders}">
           <c:set var="projectLeaders" value="${projectLeaders}<br/>${line.first_name} ${line.last_name}"/>
       </c:when>
    </c:choose>
</c:forEach>    

<%-- get the project information --%>
<sql:query var="projects">
    select id, title, summary, state, to_char(created,'YYYY-Mon-DD HH:MI:SS') created, to_char(lastmodified,'YYYY-Mon-DD-HH:MI:SS') lastmodified, lastmodby, wkspaceurl, gitspaceurl from descpub_project where id = ?
    <sql:param value="${param.projid}"/>
</sql:query>

<%-- row holds the query results in an array --%>
<c:set var="row" value="${projects.rows[0]}"/>
   
<%-- Must set the first row "reset=true" in order for the rows to alternate colors. If all rows have "reset=true" then the table will not have any color --%>
<p id="pagelabel">Project Details</p>
<table class="datatable">
    <utils:trEvenOdd reset="true"><th>Title</th><td style="text-align: left">${row.title}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Project ID</th><td style="text-align: left">${row.id}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>State</th><td style="text-align: left">${row.state}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Date Created</th><td style="text-align: left">${row.created}</td></utils:trEvenOdd>
    <c:if test="${!empty row.lastmodified}">
        <utils:trEvenOdd ><th>Last Modified</th><td style="text-align: left">${row.lastmodified}</td></utils:trEvenOdd>
    </c:if>
    <c:if test="${!empty row.lastmodby}">
        <utils:trEvenOdd ><th>Modified By</th><td style="text-align: left">${row.lastmodby}</td></utils:trEvenOdd>
    </c:if>
    <utils:trEvenOdd ><th>Confluence Url</th><td style="text-align: left">${empty row.wkspaceurl ? 'none' : row.wkspaceurl}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Github Url</th><td style="text-align: left">${empty row.gitspaceurl ? 'none' : row.gitspaceurl}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Summary</th><td style="text-align: left">${row.summary}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Project leaders</th><td style="text-align: left">${projectLeaders}</td></utils:trEvenOdd>

    <c:if test="${gm:isUserInGroup(pageContext,projectLeadGrpName) || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">
      <utils:trEvenOdd ><th>Edit project</th><td style="text-align: left"><a href="show_project.jsp?projid=${param.projid}&swgid=${param.swgid}">${row.id}</a></td></utils:trEvenOdd>
    </c:if>
    <c:if test="${gm:isUserInGroup(pageContext,projectGrpName) || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">
      <utils:trEvenOdd ><th>Document </th><td style="text-align: left"><a href="addPublication.jsp?task=create_publication_form&projid=${param.projid}&swgid=${param.swgid}">Add</a></td></utils:trEvenOdd>
    </c:if>
      
</table>
 
 <c:if test="${docs.rowCount > 0}">
    <p></p>
    <p id="pagelabel">${docs.rowCount} Document Entries</p>

    <display:table class="datatable"  id="rows" name="${docs.rows}" cellpadding="5" cellspacing="8">
        <c:set var="paperGrpName" value="paper_${rows.paperid}"/>
        <c:set var="paperLeadGrpName" value="paper_leads_${rows.paperid}"/>
        <display:column title="Document ID" style="text-align:left;" sortable="true" headerClass="sortable">
            DESC-${rows.paperid}
        </display:column>
        <display:column title="Date Created" property="createdate" style="text-align:left;" sortable="true" headerClass="sortable"/>
        <display:column title="Title" paramProperty="title" style="text-align:left;" sortable="true" headerClass="sortable">
            <a href="show_pub.jsp?paperid=${rows.paperid}">${rows.title}</a>
        </display:column>
        <display:column title="Document Type" property="pubtype" style="text-align:left;" sortable="true" headerClass="sortable"/>
        <display:column title="Number of Versions" style="text-align:left;" sortable="true" headerClass="sortable">
            <sql:query var="vers">
                select count(*) tot from descpub_publication_versions where paperid = ?
                <sql:param value="${rows.paperid}"/>
            </sql:query>
            ${vers.rows[0].tot}
        </display:column>
        <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,paperLeadGrpName) || gm:isUserInGroup(pageContext,paperGrpName) || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )}">
            <display:column title="Edit doc" href="editLink.jsp" paramId="paperid" property="paperid" paramProperty="paperid" sortable="true" headerClass="sortable"/>
        </c:if>
    </display:table>
    <p/> 
</c:if>

</html>
