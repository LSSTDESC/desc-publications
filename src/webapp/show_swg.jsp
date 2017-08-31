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
       swgname = science working group name
       Users cannot change name of a group, that leads to inconsistencies between profile_group and profile_ug.  Users can request to delete a group. 
    --%>
    
    <h2>Science Working Group: ${param.swgname}</h2>
    
    <c:set var="convenerPool" value="lsst-desc-full-members"/>
    
    <sql:query var="swgs" dataSource="jdbc/config-dev">
        select id, name, email, profile_group_name as pgn, convener_group_name as cgn from descpub_swg where id = ? order by id
        <sql:param value="${param.swgid}"/>
    </sql:query>
     
    <c:set var="pgn" value="${swgs.rows[0].pgn}"/>   
    <c:set var="cgn" value="${swgs.rows[0].cgn}"/>   
    <c:set var="swgid" value="${param.swgid}"/> 
    <c:set var="swgname" value="${swgs.rows[0].name}"/>
    
    <sql:query var="projects" dataSource="jdbc/config-dev">
        select p.id, p.keyprj, p.title, p.state, p.created, wg.name swgname, wg.id swgid, wg.convener_group_name cgn, p.abstract abs, p.comments 
        from descpub_project p left join descpub_project_swgs ps on p.id=ps.project_id
        left join descpub_swg wg on ps.swg_id=wg.id where wg.id = ? order by p.title
        <sql:param value="${param.swgid}"/>
    </sql:query>    
      
        <%--
    <sql:query var="pubs" dataSource="jdbc/config-dev">
        select pub.abstract, pub.added, pub.arxiv, pub.responsible_pb_reader reader, pub.builder_eligible buildable, pub.comments comm, pub.cwr_comments, pub.cwr_end_date, pub.id, pub.journal,
        pub.journal_review, pub.keypub, pub.project_id, pub.published_reference, pub.state, pub.title from descpub_publication pub 
        join descpub_project pj on pub.project_id = pj.id 
    </sql:query> --%>
     
    <c:choose>  
        <c:when test="${!empty param.swgid}">
         <%-- Don't allow deletion of swgs per S.Digel, 18jul17.   --%>
            
               <%--   <c:if test="${gm:isUserInGroup(pageContext,projects.rows[0].cgn)}"> --%>
               <c:if test="${gm:isUserInGroup(pageContext,'lsst-desc-publications')}">
                   
                <strong><a href="project_details.jsp?task=create_proj_form&swgname=${param.swgname}&swgid=${param.swgid}">create project</a></strong>
                <p/>
                <hr/>
                <p/>
                <c:if test="${projects.rowCount > 0}">
                   Manage <strong>conveners</strong> of the working group <br/>
                   <tg:groupMemberEditor candidategroup="${convenerPool}" groupname="${cgn}" returnURL="show_swg.jsp?swgid=${swgid}&swgname=${swgname}"/>
                    <p/>
                    <hr/>
                </c:if>
                    
                <p/>
                <c:if test="${projects.rowCount > 0}">
                    Manage <strong>members</strong> of the working group<br/>
                   <tg:groupMemberEditor candidategroup="${convenerPool}" groupname="${pgn}" returnURL="show_swg.jsp?swgid=${swgid}&swgname=${swgname}"/>
                    <p/>
                    <hr/>
                </c:if>
                    
            </c:if>
             <strong>Projects</strong><br/>
             <display:table class="datatable" id="proj" name="${projects.rows}">
                 <display:column property="id" title="Id" sortable="true" headerClass="sortable">
                    <a href="show_project.jsp?projid=${proj.id}&swgid=${param.swgid}&name=${proj.title}">${proj.id}</a> 
                 </display:column>
                 <display:column title="Project Title" sortable="true" headerClass="sortable">
                    <a href="show_project.jsp?projid=${proj.id}&swgid=${param.swgid}&name=${proj.title}">${proj.title}</a> 
                 </display:column>
                 <display:column title="Members" sortable="true" headerClass="sortable">
                     TBD
                 </display:column>
                 <display:column title="State" sortable="true" headerClass="sortable">
                     ${proj.state}
                 </display:column>
                 <display:column title="Documents" sortable="true" headerClass="sortable">
                     TBD
                 </display:column>
                 <display:column title="Publications" sortable="true" headerClass="sortable">
                     <sql:query var="results" dataSource="jdbc/config-dev">
                        select p.id projid, ub.id pubid, ub.keypub, ub.state, ub.title, ub.keypub
                        from descpub_project p left join descpub_project_swgs ps on p.id=ps.project_id
                        left join descpub_swg wg on ps.swg_id=wg.id 
                        left join descpub_publication ub on ub.project_id = p.id
                        where wg.id = ? and p.id = ?
                        <sql:param value="${param.swgid}"/>
                        <sql:param value="${proj.id}"/>
                     </sql:query>
                     <c:forEach var="pub" items="${results.rows}">
                        <a href="show_pub.jsp?pubid=${pub.pubid}&projid=${proj.id}">${pub.title}</a><br/>
                     </c:forEach>
                 </display:column>
             </display:table>
        </c:when>
        <c:otherwise>
            nothing to do
        </c:otherwise>
    </c:choose>    
            
</body>
</html>
    
    
</html>
