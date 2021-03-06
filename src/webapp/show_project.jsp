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
      <title>LSST DESC Project ${param.projid}</title>
</head>

<body>
    <%-- show_project allows edits to project details by project leads only --%>
    <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>
    
    <c:if test="${empty param.projid}">  
      <c:redirect url="noPermission.jsp?errmsg=12"/>  
    </c:if>
    
    <tg:underConstruction/>

    <c:set var="projid" value="${param.projid}"/>
    <c:if test="${empty param.swgid}">
        <sql:query var="swg">
            select swg_id from descpub_project_swgs where project_id = ?
            <sql:param value="${param.projid}"/>
        </sql:query>
        <c:if test="${swg.rowCount < 1}">
           <c:redirect url="noPermission.jsp?errmsg=15"/>
        </c:if>
    </c:if>
    <c:set var="swgid" value="${param.swgid}"/>
   <%--  <c:set var="memberPool" value="lsst-desc-full-members"/> NOT USED? --%>
    <c:set var="groupname" value="project_leads_${projid}"/>
    <c:set var="grpmember" value="project_${projid}"/>
    <c:set var="returnURL" value="show_project.jsp?projid=${projid}&swgid=${swgid}"/>
    
    
    <%-- is user allowed to add documents to this project --%>
    <sql:query var="canUser"> <%-- check if user is in one of the allowed groups --%>
        select memidnum from profile_ug where group_id=? and user_id=? and experiment=?
        <sql:param value="${grpmember}"/>
        <sql:param value="${userName}"/>
        <sql:param value="${appVariables.experiment}"/>
    </sql:query>
    <c:if test="${!empty canUser.rows[0].memidnum}">
        <c:set var="addDocs" value="true"/>
    </c:if> 
       
     <sql:query var="projDetails">
        select * from descpub_project where id = ?
        <sql:param value="${projid}"/>
    </sql:query>
    
    <sql:query var="pubs">
        select paperid, title, createdate, pubtype from descpub_publication where project_id = ?
        <sql:param value="${projid}"/>
    </sql:query> 
    
    <sql:query var="leads">
        select convener_group_name cgn from descpub_swg where id = ?
        <sql:param value="${swgid}"/>
    </sql:query> 
        
    <c:set var="pubtype" value="${pubs.rows[0].pubtype}"/> 
    <c:set var="leadersgrp" value="${leads.rows[0].cgn}"/>
    <c:set var="memgrp" value="project_${projid}"/>
    
    <!-- Prominently display project number and title, and provide URL -->
    <h1><strong>Project ${param.projid}: ${projDetails.rows[0].title}</strong></h1> 
    
    <tg:editProject projid="${projid}" swgid="${swgid}" returnURL="show_project.jsp?projid=${projid}&swgid=${swgid}"/> 
  
    <p><p/>
    
    <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,leadersgrp) || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )}">
        <p id="pagelabel">Add or Remove Project Leads</p>
        <tg:groupMemberEditor groupname="${groupname}" returnURL="${returnURL}"/> 
    </c:if>
        
       
    <c:if test="${pubs.rowCount > 0}">
         <hr align="left" width="45%"/>
        <p></p>
        
        <p id="pagelabel">List of Document Entries (Total: ${pubs.rowCount})</p>
        
        <display:table class="datatable"  id="rows" name="${pubs.rows}">
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
                <c:choose>    
                    <c:when test="${vers.rowCount > 0}">
                        <a href="uploadPub.jsp?paperid=${rows.paperid}">${vers.rows[0].tot}</a>
                    </c:when>
                    <c:when test="${vers.rowCount < 1}">
                        ${vers.rows[0].tot}
                    </c:when>
                </c:choose>
            </display:column>
            <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,leadersgrp) || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )}">
              <display:column title="Edit" href="editLink.jsp" paramId="paperid" property="paperid" paramProperty="paperid" sortable="true" headerClass="sortable"/>
            </c:if>
        </display:table>
        <p/> 
    </c:if>
    <p/>
 
    
    <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin') || gm:isUserInGroup(pageContext,leadersgrp) || gm:isUserInGroup(pageContext,'GroupManagerAdmin' )}">
      <c:if test="${gm:isUserInGroup(pageContext,projectGrpName) || gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">
          <table class="datatable">
            <utils:trEvenOdd reset="true"><th>Authorized tasks</th><td style="text-align:left;"><a href="addPublication.jsp?task=create_publication_form&projid=${param.projid}&swgid=${param.swgid}">Add document to project ${param.projid}</a></td></utils:trEvenOdd>
          </table>
      </c:if>
    </c:if>   
        
</body>
</html>
    
    
</html>

