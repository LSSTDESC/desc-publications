<%-- 
    Document   : publications
    Created on : Jun 30, 2017, 10:30:01 AM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html>

 <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <script src="js/jquery-1.11.1.min.js"></script>
      <script src="js/jquery.validate.min.js"></script>
      <link rel="stylesheet" href="css/site-demos.css">
     
      <title>SWG Page</title>
</head>

<body>
    <%-- Notes:
       pgn = profile group name
       cgn = convener group name
       swgname = science working group name
       Users cannot change name of a group, that leads to inconsistencies between profile_group and profile_ug.  Users can request to delete a group. 
    --%>
    <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
        <c:redirect url="noPermission.jsp?errmsg=1"/>
    </c:if>
    
    <tg:underConstruction/>

    <h2>Working Group: ${param.swgname}</h2>
    
    <c:set var="convenerPool" value="lsst-desc-full-members"/>
    <c:set var="pubPool" value="lsst-desc-publications"/>
    <c:set var="pubAdmin" value="lsst-desc-publications-admin"/>
    
    <sql:query var="swgs">
        select id, name, email, profile_group_name as pgn, convener_group_name as cgn from descpub_swg where id = ? order by id
        <sql:param value="${param.swgid}"/>
    </sql:query>
     
    <c:set var="pgn" value="${swgs.rows[0].pgn}"/>   
    <c:set var="cgn" value="${swgs.rows[0].cgn}"/>   
    <c:set var="swgid" value="${param.swgid}"/> 
    <c:set var="swgname" value="${swgs.rows[0].name}"/>
    
    <sql:query var="projects">
        select p.id, p.keyprj, p.title, p.state, p.created, wg.name swgname, wg.id swgid, wg.profile_group_name pgn, wg.convener_group_name cgn, p.summary 
        from descpub_project p left join descpub_project_swgs ps on p.id=ps.project_id
        left join descpub_swg wg on ps.swg_id=wg.id where wg.id = ? order by p.title
        <sql:param value="${param.swgid}"/>
    </sql:query>    
      
        <%--
     
    <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">  
        <c:redirect url="noPermission.jsp?errmsg=4"/>
    </c:if> --%>
                    
   <%--  <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}"> --%>     
    <c:choose>  
    <%-- <c:when test="${!empty param.swgid && gm:isUserInGroup(pageContext,pubAdmin) || gm:isUserInGroup(pageContext,projects.rows[0].pgn) }"> --%>
       <c:when test="${!empty param.swgid && gm:isUserInGroup(pageContext,'lsst-desc-members')}">
         <%-- Don't allow deletion of swgs per S.Digel, 18jul17.   --%>
            
            <c:if test="${gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,cgn) || gm:isUserInGroup(pageContext,'lsst-desc-publications-admin')}">
                <form action="project_details.jsp">
                    <input type="hidden" name="task" value="create_proj_form"/>
                    <input type="hidden" name="swgname" value="${param.swgname}"/>
                    <input type="hidden" name="swgid" value="${param.swgid}"/>
                    <input type="submit" value="Create Project"/>
                </form>
            </c:if>
             
             <p/>        
             <strong>Projects</strong><br/>
             <display:table class="datatable" id="proj" name="${projects.rows}">
                 <display:column title="Id" sortable="true" headerClass="sortable">
                    <a href="show_project.jsp?projid=${proj.id}&swgid=${param.swgid}&wgname=${proj.title}">${proj.id}</a> 
                 </display:column>
                 <display:column title="Project Title" sortable="true" headerClass="sortable">
                    <a href="show_project.jsp?projid=${proj.id}&swgid=${param.swgid}">${proj.title}</a> 
                 </display:column>
                 <display:column title="State" sortable="true" headerClass="sortable">
                     ${proj.state}
                 </display:column>
                 <display:column title="# of Documents" sortable="true" headerClass="sortable">
                     <sql:query var="results">
                        select count(*) tot from descpub_publication pub join descpub_project_papers proj on pub.paperid=proj.paperid where proj.project_id = ?
                        <sql:param value="${proj.id}"/>
                     </sql:query>
                     ${results.rows[0].tot}
                 </display:column>
             </display:table>
        </c:when>
        <c:otherwise>
            Only DESC members and members of the following groups have access:<br/> 
            ${cgn}<br/>
            ${pgn}  
        </c:otherwise>
    </c:choose>    
  <%--  </c:if> --%>
            
</body>
</html>
    
    
</html>
