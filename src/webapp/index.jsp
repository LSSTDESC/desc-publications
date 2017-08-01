<%-- 
    Document   : publications
    Created on : Jun 30, 2017, 10:30:01 AM
    Author     : chee
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>

<!DOCTYPE html>

<html>
 <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <script src="js/jquery-1.11.1.min.js"></script>
      <script src="js/jquery.validate.min.js"></script>
      <link rel="stylesheet" href="css/site-demos.css">
      <title>LSST DESC Publications Board</title>
</head>

<body>
    
     <c:set var="convenLink" value="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/group.jsp?name="/>
        
     <h2>LSST-DESC Publications Board</h2>
     
     <%-- links to other pages --%>
     <h4><a href="members.jsp">members</a></h4>
     <h4><a href="projects.jsp">projects</a></h4>
     
     <%-- Queries --%>
     <%-- 
         <sql:query var="pubdet" dataSource="jdbc/config-dev">
            select pb.id,pb.state,pb.title,pb.journal,pb.abstract,pb.added,pb.builder_eligible,pb.comments,pb.keypub,pb.cwr_end_date,pb.assigned_pb_reader,pb.cwr_comments,
            pb.arxiv,pb.telecon,pb.journal_review,pb.published_reference,pb.project_id
            from descpub_publication pb join descpub_author da on pb.id=da.publication_id 
            join descpub_project dp on dp.id=pb.project_id where pb.id=?
            <sql:param value="${param.id}"/>
        </sql:query> --%>
     
     <c:set var="memberPool" value="lsst-desc-full-members"/>
     
         <sql:query var="swgs" dataSource="jdbc/config-dev">
            select id, name, email, profile_group_name as pgn, convener_group_name as cgn from descpub_swg 
            order by id
        </sql:query>
        
        <%--    
        <sql:query var="projects" dataSource="jdbc/config-dev">
            select p.id, p.keyprj, p.title, p.state, wg.name, p.abstract as abs, p.state, p.created, p.comments, p.keyprj, p.active, wg.convener_group_name as cgn, wg.profile_group_name as pgn
            from descpub_project p join descpub_project_swgs ps on p.id=ps.project_id
            join descpub_swg wg on ps.swg_id=wg.id order by p.id   
        </sql:query>  --%>
            
        <sql:query var="candidates" dataSource="jdbc/config-dev">
            select me.memidnum, me.firstname, me.lastname from um_member me join um_project_members pm on me.memidnum=pm.memidnum 
            join profile_ug ug on ug.memidnum=pm.memidnum and ug.group_id = ?
            where pm.activestatus='Y' and pm.project = ?
            <sql:param value="${memberPool}"/>
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
            
        <c:if test="${swgs.rowCount > 0}">
            <display:table class="datatable"  id="Row" name="${swgs.rows}">
                <display:column title="Science Working Group" sortable="true" headerClass="sortable">
                        <a href="show_swg.jsp?swgid=${Row.id}&swgname=${Row.name}">${Row.name}</a>
                    </display:column>
                    <display:column title="Mail List" sortable="true" headerClass="sortable">
                        <a href="mailto:${Row.email}">${Row.email}</a>
                    </display:column>
                    <display:column title="Conveners" sortable="true" headerClass="sortable">
                        <sql:query var="conveners" dataSource="jdbc/config-dev">
                            select me.firstname, me.lastname from um_member me join profile_ug ug on me.memidnum=ug.memidnum and ug.group_id=?
                            <sql:param value="${Row.cgn}"/>
                        </sql:query>
                        <c:if test="${conveners.rowCount>0}">
                            <display:table class="datatable" id="cRow" name="${conveners.rows}"/>
                        </c:if>
                    </display:column>
            </display:table>
        </c:if>     
            
</body>

</html>
