<%-- 
    Document   : publications
    Created on : Jun 30, 2017, 10:30:01 AM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/utils" prefix="utils"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>


<!DOCTYPE html>
<html>
 <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <script src="js/jquery-1.11.1.min.js"></script>
      <script src="js/jquery.validate.min.js"></script>
      <link rel="stylesheet" href="css/site-demos.css">
      <link rel="stylesheet" href="css/pubstyles.css">
      <title>Working Groups Page</title>
</head>

   <body>
    <%-- Notes:
       pgn = profile group name
       cgn = convener group name
       swgname = science working group name
       Users cannot change name of a group, that leads to inconsistencies between profile_group and profile_ug.  Users can request to delete a group. 
    --%>
    <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
        <c:redirect url="noPermission.jsp?errmsg=7"/>
    </c:if>
    
    <tg:underConstruction/>
    
    <c:set var="convenerPool" value="lsst-desc-full-members"/>
    <c:set var="pubPool" value="lsst-desc-publications"/>
    <c:set var="pubAdmin" value="lsst-desc-publications-admin"/>
    
    <sql:query var="swgs">
        select id, name, email, convener_group_name as cgn from descpub_swg where id = ? order by id
        <sql:param value="${param.swgid}"/>
    </sql:query>
        
    <c:set var="cgn" value="${swgs.rows[0].cgn}"/>   
    <c:set var="swgid" value="${param.swgid}"/> 
    <c:set var="swgname" value="${swgs.rows[0].name}"/>
    <c:set var="convenerList" value=""/>
    
    <sql:query var="projects">
        select p.id, p.title, p.projectstatus, p.created, p.confluenceurl, p.lastmodby, p.lastmodified, wg.name swgname, wg.id swgid, wg.convener_group_name cgn, p.summary 
        from descpub_project p left join descpub_project_swgs ps on p.id=ps.project_id
        left join descpub_swg wg on ps.swg_id=wg.id where wg.id = ? order by p.id
        <sql:param value="${param.swgid}"/>
    </sql:query>
        
    <%-- working groups must have conveners assigned otherwise noPermission called --%>
    <sql:query var="conveners">
        select u.first_name, u.last_name, u.email, ug.group_id, u.memidnum from profile_user u join profile_ug ug on u.memidnum=ug.memidnum 
        where u.active='Y' and ug.group_id = ? and u.experiment = ?
        <sql:param value="${cgn}"/>
        <sql:param value="${appVariables.experiment}"/>
    </sql:query>
    
    <c:if test="${conveners.rowCount < 1}">
       <c:redirect url="noPermission.jsp?errmsg=8"/> 
    </c:if>
        
    <c:forEach var="c" items="${conveners.rows}">
        <c:choose>
        <c:when test="${empty convenerList}">
            <c:set var="convenerList" value="<a href=mailto:${c.email}>${c.first_name} ${c.last_name}</a>"/>
            <c:set var="allconveners" value="${c.email}"/>
        </c:when>
        <c:when test="${!empty convenerList}">
            <c:set var="convenerList" value="${convenerList}, <a href=mailto:${c.email}>${c.first_name} ${c.last_name}</a>"/>
            <c:set var="allconveners" value="${allconveners},${c.email}"/>
        </c:when>
        </c:choose>
    </c:forEach>
             
    <h2>Working Group(s): ${swgname}</h2>
    <p id="pagelabel"><a href="mailto:${allconveners}">Conveners</a>: ${convenerList}</p>
    
       <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-members')}">
          
            <strong>Projects</strong><br/>
            <display:table class="datatable" id="proj" name="${projects.rows}">
               <display:column title="Id" property="id" sortable="true" headerClass="sortable"/>
               <display:column title="Project Title" style="text-align:left;" sortable="true" headerClass="sortable">
                  <a href="projectView.jsp?projid=${proj.id}&swgid=${param.swgid}">${proj.title}</a>
               </display:column>   
               <display:column property="created" title="Created" style="text-align:left;" sortable="true" headerClass="sortable"/>
               <display:column property="lastmodified" title="Last modified" style="text-align:left;" sortable="true" headerClass="sortable"/>
               <display:column title="# of Docs">
                   <sql:query var="results">
                     select count(*) tot from descpub_publication where project_id = ?
                     <sql:param value="${proj.id}"/>
                   </sql:query>
                   ${results.rows[0].tot}
               </display:column>
               <c:if test="${gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,cgn) || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">
                   <display:column title="Edit Project">
                       <a href="show_project.jsp?projid=${proj.id}&swgid=${param.swgid}">e</a>
                   </display:column>
                      
                   <display:column title="Add doc" style="text-align:right;">
                       <a href="addPublication.jsp?task=create_publication_form&projid=${proj.id}&swgid=${param.swgid}">a</a>
                   </display:column>    

               </c:if>   
            </display:table>
        </c:if>  
        <p></p>
        <c:if test="${gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,cgn) || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">
          <table class="datatable">
            <utils:trEvenOdd reset="true"><th>Authorized tasks</th><td style="text-align: left"> <a href="project_details.jsp?task=create_proj_form&swgid=${param.swgid}">Add a project</a></td></utils:trEvenOdd>
            <utils:trEvenOdd reset="true"><th></th><td style="text-align: left"><a href="addPublication.jsp?task=create_publication_form&swgid=${param.swgid}&projid=0">Add a project-less document</a></td></utils:trEvenOdd>
          </table>
        </c:if>
         
                       
   </body>
</html>
