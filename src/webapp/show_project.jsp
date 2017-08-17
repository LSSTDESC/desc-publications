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
      <link rel="stylesheet" href="css/site-demos.css">
      <title>LSST-DESC Project ${param.projid}</title>
</head>

<body>
    
    <c:set var="projid" value="${param.projid}"/>
    <c:set var="swgid" value="${param.swgid}"/>
    <c:set var="memberPool" value="lsst-desc-full-members"/>
       
     <sql:query var="publications" dataSource="jdbc/config-dev">
        select pb.id,pb.state,pb.title,pb.journal,pb.abstract,pb.added,pb.builder_eligible,pb.comments,pb.keypub,pb.cwr_end_date,pb.assigned_pb_reader,pb.cwr_comments,
        pb.arxiv,pb.telecon,pb.journal_review,pb.published_reference,pb.project_id
        from descpub_publication pb join descpub_project dp on dp.id=pb.project_id where dp.id=?
        <sql:param value="${param.projid}"/>
    </sql:query> 
    
    <sql:query var="projects" dataSource="jdbc/config-dev">
        select p.id, p.keyprj, p.title, p.state, to_char(p.created,'YYYY-MON-DD') crdate, p.created, wg.name swgname, wg.id swgid, wg.convener_group_name cgn, p.abstract abs, p.comments 
        from descpub_project p left join descpub_project_swgs ps on p.id=ps.project_id
        left join descpub_swg wg on ps.swg_id=wg.id where p.id = ?  
        <sql:param value="${projid}"/>
    </sql:query>  
    
    <sql:query var="pubs" dataSource="jdbc/config-dev">
        select id, state, title, abstract, added, builder_eligible, keypub from descpub_publication where project_id = ? 
        order by title
        <sql:param value="${projid}"/>
    </sql:query>  
     
    <sql:query var="mems" dataSource="jdbc/config-dev">
        select wg.profile_group_name pgn, wg.convener_group_name cgn, wg.name from descpub_swg wg join descpub_project_swgs ps on ps.project_id=?
        and ps.swg_id = wg.id and ps.swg_id = ?
        <sql:param value="${projid}"/>
        <sql:param value="${swgid}"/>
    </sql:query>  
     
    <c:if test="${param.update == 'done'}">
        <div style="color: #0000FF">
            Project updated
        </div>
    </c:if> 
    <p/>
    <h2>Project: [${projid}] ${projects.rows[0].title}  </h2>
    <h3>Created: ${projects.rows[0].crdate}</h3>
    
    <tg:editProject experiment="${appVariables.experiment}" projid="${projid}" swgid="${swgid}" returnURL="show_project.jsp"/>  
    <p/>
     
  <display:table class="datatable" id="Rows" name="${pubs.rows}" defaultsort="1">
        <display:column title="Id" sortable="true" headerClass="sortable">
            <a href="show_pub.jsp?pubid=${Rows.id}&projid=${projid}&swgid=${swgid}">${Rows.id}<a/>
        </display:column>
        <display:column title="Title" sortable="true" headerClass="sortable">
            <a href="show_pub.jsp?pubid=${Rows.id}&projid=${projid}&swgid=${swgid}">${Rows.title}<a/>
        </display:column>
        <display:column property="state" title="State" sortable="true" headerClass="sortable"/>
        <display:column property="abstract" title="Abstract" sortable="true" headerClass="sortable"/>
        <display:column property="added" title="Created" sortable="true" headerClass="sortable"/> 
        <display:column property="builder_eligible" title="Builder" sortable="true" headerClass="sortable"/>        
        <display:column property="keypub" title="Key Pub" sortable="true" headerClass="sortable"/>        
  </display:table>  

  <p/>
  <tg:addPublication experiment="${appVariables.experiment}" projid="${projid}" swgid="${swgid}" returnURL="show_project.jsp?projid=${projid}&swgid=${swgid}"/>  
  <p/>
  <tg:addDocument swgid="${swgid}" userName="${userName}" experiment="${appVariables.experiment}" projid="${projid}" returnURL="show_project.jsp"/>  
 
</body>
</html>
    
    
</html>

