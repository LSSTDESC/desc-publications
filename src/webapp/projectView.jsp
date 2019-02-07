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
 
 <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <link rel="stylesheet" type="text/css" href="css/pubstyles.css">
      <title>LSST-DESC Project ${param.projid}</title>
</head>

<tg:underConstruction/>

<c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
     <c:redirect url="noPermission.jsp?errmsg=7"/>
</c:if>

<c:catch var="chkProjID">
    <sql:query var="validID">
        select id from descpub_project where id = ?
        <sql:param value="${param.projid}"/>
    </sql:query>
</c:catch>
 
<c:if test="${!empty chkProjID || validID.rowCount < 1}"> 
    <c:redirect url="noPermission.jsp?errmsg=11"/>
</c:if>
<c:set var="paperGrpName" value="paper_${param.projid}"/>
<c:set var="paperLeadGrpName" value="paper_leads_${param.projid}"/>
<c:set var="projectGrpName" value="project_${param.projid}"/>
<c:set var="projectLeadGrpName" value="project_leads_${param.projid}"/>
       
<%-- get memidnum for project membership --%>
<sql:query var="userInfo">
    select memidnum from profile_user where user_name = ? and experiment = ?
    <sql:param value="${userName}"/>
    <sql:param value="${appVariables.experiment}"/>
</sql:query>
<c:set var="memidnum" value="${userInfo.rows[0]['memidnum']}"/>

<%-- is user allowed to edit. if member of project then user can also edit papers assoc. with project 
<sql:query var="canUser">  
    select memidnum from profile_ug where group_id in (?,?) and user_id=? and experiment = ?
    <sql:param value="${projectGrpName}"/>
    <sql:param value="${projectLeadGrpName}"/>
    <sql:param value="${userName}"/>
    <sql:param value="${appVariables.experiment}"/>
</sql:query>
<c:if test="${!empty canUser.rows[0].memidnum}">
    <c:set var="canEditProject" value="true"/>
</c:if> --%>
    
<%-- get all the papers under this project --%>
<sql:query var="docs">
   select paperid, title, can_request_authorship, to_char(createdate,'YYYY-Mon-DD HH:MI:SS') createdate, pubtype 
   from descpub_publication where project_id = ? order by case when pubtype='Journal paper' then 1 else 2 end
   <sql:param value="${param.projid}"/>
</sql:query>
    
<%-- define project variables --%>
<c:set var="projectLeadGrpName" value="project_leads_${param.projid}"/>
<c:set var="projectGrpName" value="project_${param.projid}"/>
<c:set var="projectLeaders" value=""/>
<c:set var="leadAddrs" value=""/>

<sql:query var="leads">
    select u.first_name, u.last_name, u.email, u.memidnum, u.user_name from profile_user u join profile_ug ug on u.memidnum = ug.memidnum and u.experiment = ug.experiment
    where ug.group_id = ? and ug.experiment = ? order by u.last_name
    <sql:param value="${projectLeadGrpName}"/>
    <sql:param value="${appVariables.experiment}"/>
</sql:query>
<c:forEach var="line" items="${leads.rows}">
    <c:choose>
       <c:when test="${empty projectLeaders}">
           <c:set var="projectLeaders" value="${line.first_name} ${line.last_name}"/>
           <c:set var="leadAddrs" value="${line.email}"/>
       </c:when>
       <c:when test="${!empty projectLeaders}">
           <c:set var="projectLeaders" value="${projectLeaders}<br/>${line.first_name} ${line.last_name}"/>
           <c:set var="leadAddrs" value="${leadAddrs},${line.email}"/>
       </c:when>
    </c:choose>
</c:forEach>    
    
<%-- get the project information --%>
<sql:query var="projsrminfo">
  select srmtitle, srmtype from descpub_project_srm_info where project_id = ?
  <sql:param value="${param.projid}"/>
</sql:query>  
  
<sql:query var="projects">
    select id, title, summary, projectstatus, to_char(created,'YYYY-Mon-DD HH:MI:SS') created, to_char(lastmodified,'YYYY-Mon-DD-HH:MI:SS') lastmodified, lastmodby, 
    confluenceurl, gitspaceurl from descpub_project where id = ?
    <sql:param value="${param.projid}"/>
</sql:query> 

<sql:query var="prsw"> <%-- get working groups associated with project --%>
    select sw.id, sw.name from descpub_swg sw  join descpub_project_swgs ps on sw.id = ps.swg_id where ps.project_id = ?
    <sql:param value="${param.projid}"/>
</sql:query> 
    
<c:if test="${prsw.rowCount > 0}">
    <c:forEach var="ps" items="${prsw.rows}">
        <c:choose>
            <c:when test="${empty projswgs}">
                <c:set var="projswgs" value="<a href=show_swg.jsp?swgid=${ps.id}>${ps.name}</a>"/>
            </c:when>
            <c:when test="${!empty projswgs}">
                <c:set var="projswgs" value="${projswgs}, <a href=show_swg.jsp?swgid=${ps.id}>${ps.name}</a>"/> 
            </c:when>
        </c:choose>
    </c:forEach>  
</c:if>
    
<%-- row holds the query results in an array --%>
<c:set var="row" value="${projects.rows[0]}"/>
   
<%-- Must set the first row "reset=true" in order for the rows to alternate colors. If all rows have "reset=true" then the table will not have any color --%>
<p id="pagelabel">Project Details</p>
<table class="datatable">
    <utils:trEvenOdd reset="true"><th>Title</th><td style="text-align: left">${row.title}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Project ID</th><td style="text-align: left">${row.id}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>WGs</th><td style="text-align: left">${projswgs}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>State</th><td style="text-align: left">${row.projectstatus}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Date Created</th><td style="text-align: left">${row.created}</td></utils:trEvenOdd>
    <c:if test="${!empty row.lastmodified}">
        <utils:trEvenOdd ><th>Last Modified</th><td style="text-align: left">${row.lastmodified}</td></utils:trEvenOdd>
    </c:if>
    <c:if test="${!empty row.lastmodby}">
        <utils:trEvenOdd ><th>Modified By</th><td style="text-align: left">${row.lastmodby}</td></utils:trEvenOdd>
    </c:if>
    <c:choose>
    <c:when test="${fn:startsWith(row.confluenceurl,'https://confluence')}">
        <utils:trEvenOdd ><th>Confluence Url</th><td style="text-align: left"><a href=${row.confluenceurl}>${row.confluenceurl}</a></td></utils:trEvenOdd>
    </c:when>
    <c:when test="${! fn:startsWith(row.confluenceurl,'https')}">
        <utils:trEvenOdd ><th>Confluence Url</th><td style="text-align: left">none</td></utils:trEvenOdd>
    </c:when>
    </c:choose>
    <c:choose>
    <c:when test="${fn:startsWith(row.gitspaceurl,'https://github')}">
        <utils:trEvenOdd ><th>Github Url</th><td style="text-align: left"><a href=${row.gitspaceurl}>${row.gitspaceurl}</a></td></utils:trEvenOdd>
    </c:when>
    <c:when test="${! fn:startsWith(row.gitspaceurl,'https://github')}">
        <utils:trEvenOdd ><th>Github Url</th><td style="text-align: left">none</td></utils:trEvenOdd>
    </c:when>
    </c:choose>
   
    <c:if test="${projsrminfo.rowCount > 0}">
        <c:set var="srmactList" value=""/>
        <c:set var="srmdelList" value=""/>

        <c:forEach var="ad" items="${projsrminfo.rows}">
            <c:choose>
            <c:when test="${empty srmactList && ad.srmtype == 'activity'}">
                <c:set var="srmactList" value="${ad.srmtitle}<br/>"/>
            </c:when>
            <c:when test="${! empty srmactList && ad.srmtype == 'activity'}">
                <c:set var="srmactList" value="${srmactList} ${ad.srmtitle}<br/>"/>
            </c:when>
            <c:when test="${empty srmdelList && ad.srmtype == 'deliverable'}">
                <c:set var="srmdelList" value="${ad.srmtitle}<br/>"/>
            </c:when>
            <c:when test="${! empty srmdelList && ad.srmtype == 'deliverable'}">
                <c:set var="srmdelList" value="${srmdelList} ${ad.srmtitle}<br/>"/>
            </c:when>
            </c:choose>
        </c:forEach>
        <utils:trEvenOdd ><th>SRM activity</th><td style="text-align: left">${srmactList}</td></utils:trEvenOdd>
        <utils:trEvenOdd ><th>SRM deliverable</th><td style="text-align: left">${srmdelList}</td></utils:trEvenOdd>
    </c:if>
     
    <utils:trEvenOdd ><th>Summary</th><td style="text-align: left">${row.summary}</td></utils:trEvenOdd>
    <utils:trEvenOdd ><th>Project leaders</th><td style="text-align: left">${projectLeaders}</td></utils:trEvenOdd>
    
    <utils:trEvenOdd ><th>Email to</th><td style="text-align: left"><a href="mailto:${leadAddrs}">project leaders</a></td><td></td></utils:trEvenOdd>  
   
    <c:if test="${gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,projectLeadGrpName) || gm:isUserInGroup(pageContext,projectGrpName)}">
      <utils:trEvenOdd ><th>Edit project</th><td style="text-align: left"><a href="show_project.jsp?projid=${param.projid}&swgid=${param.swgid}">${row.id}</a></td></utils:trEvenOdd>
    </c:if>

</table>

<table class="datatable">
    <utils:trEvenOdd  reset="true"><th>(Un)Subscribe from/to Project</th><td></td><td>
      <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-members')}">
         <c:set var="returnURL" value="projectView.jsp?projid=${param.projid}&swgid=${param.swgid}"/>
        <tg:projectSubscription groupname="project_${param.projid}" memidnum="${memidnum}" userid = "${userName}" returnURL="${returnURL}"/> 
        </c:if></td>
        <tg:projectMembershipDisplay groupname="project_${param.projid}" returnURL="${returnURL}"/> 
    </utils:trEvenOdd>  
</table>
   
 
 <c:if test="${docs.rowCount > 0}">
     
    <p id="pagelabel">${docs.rowCount} Document Entries</p>

    <display:table class="datatable"  id="rows" name="${docs.rows}" cellpadding="5" cellspacing="8">
        <c:set var="paperGrpName" value="paper_${rows.paperid}"/>
        <c:set var="paperLeadGrpName" value="paper_leads_${rows.paperid}"/>
        <c:set var="authreq" value="${rows.can_request_authorship}"/>
        <display:column title="Document id" style="text-align:left;" sortable="true" headerClass="sortable">
            <a href="show_pub.jsp?paperid=${rows.paperid}">DESC-${rows.paperid}</a>
        </display:column>
        <display:column title="Date created" property="createdate" style="text-align:left;" sortable="true" headerClass="sortable"/>
        <display:column title="Title" paramProperty="title" style="text-align:left;" sortable="true" headerClass="sortable">
            <a href="show_pub.jsp?paperid=${rows.paperid}">${rows.title}</a>
        </display:column>
        <display:column title="Document type" property="pubtype" style="text-align:left;" sortable="true" headerClass="sortable"/>
        <display:column title="Number of versions" style="text-align:left;" sortable="true" headerClass="sortable">
            <sql:query var="vers">
                select count(*) tot from descpub_publication_versions where paperid = ?
                <sql:param value="${rows.paperid}"/>
            </sql:query>
            ${vers.rows[0].tot}
        </display:column>
                
        <c:if test="${gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,projectLeadGrpName) || gm:isUserInGroup(pageContext,projectGrpName)}">
            <display:column title="Edit doc" href="editLink.jsp" paramId="paperid" property="paperid" paramProperty="paperid" sortable="true" headerClass="sortable"/>
        </c:if>
                
        <c:if test="${(gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,'lsst-desc-members') || gm:isUserInGroup(pageContext,paperGrpName) || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )) && rows.can_request_authorship=='Y'}">
            <display:column title="Request authorship" href="requestAuthorship.jsp" paramId="paperid" property="paperid" paramProperty="paperid" sortable="true" headerClass="sortable"/>
        </c:if>     
    </display:table>
    <p/> 
</c:if>
    
      
<c:if test="${gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,projectLeadGrpName) || gm:isUserInGroup(pageContext,projectGrpName)}">
    <table class="datatable">
        <utils:trEvenOdd reset="true"><th>Authorized tasks</th><td style="text-align:left;"><a href="addPublication.jsp?task=create_publication_form&projid=${param.projid}&swgid=${param.swgid}">Add document to project ${param.projid}</a></td></utils:trEvenOdd>
    </table>
</c:if>
    
      

