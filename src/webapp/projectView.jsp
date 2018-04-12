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

<%-- find the project leads --%>
<c:set var="projectLeaders" value=""/>

<sql:query var="leads">
    select u.first_name, u.last_name, u.email from profile_user u join profile_ug ug on u.memidnum = ug.memidnum and u.experiment = ug.experiment
    where ug.group_id = ? and ug.experiment = ? order by u.last_name
    <sql:param value="project_leads_${param.projid}"/>
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
    select id, title, summary, state, created, lastmodified, lastmodby, wkspaceurl from descpub_project where id = ?
    <sql:param value="${param.projid}"/>
</sql:query>

<c:set var="row" value="${projects.rows[0]}"/>

<%-- Must set the first row "reset=true" in order for the rows to alternate colors. If all rows have "reset=true" then the table will not have any color--%>
<table class="datatable">
    <utils:trEvenOdd reset="true"><th>Title</th><td>${row.title}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Project ID</th><td>${row.id}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>State</th><td>${row.state}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Created</th><td>${row.created}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Last Modified</th><td>${row.lastmodified}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Modified By</th><td>${row.lastmodby}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Workspace Url</th><td>${empty row.wkspaceurl ? 'none' : row.wkspaceurl}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Summary</th><td>${row.summary}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Project leaders</th><td>${projectLeaders}</td></utils:trEvenOdd>
</table>
 

</html>