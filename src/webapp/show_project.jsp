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
        select pb.id,pb.state,pb.title,pb.journal,pb.abstract,pb.added,pb.builder_eligible,pb.comments,pb.keypub,pb.cwr_end_date,pb.responsible_pb_reader,pb.cwr_comments,
        pb.arxiv,pb.journal_review,pb.published_reference,pb.project_id
        from descpub_publication pb join descpub_project dp on dp.id=pb.project_id where dp.id=?
        <sql:param value="${projid}"/>
    </sql:query> 
        
     <sql:query var="projects" dataSource="jdbc/config-dev">
         select id, keyprj, title, state, to_char(created,'YYYY-MON-DD') crdate, to_char(lastmodified,'YYYY-MON-DD') moddate,
        created, abstract abs, comments from descpub_project where id = ?
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
     
    <c:if test="${param.updateProj == 'done'}">
        <div style="color: #0000FF">
            Project updated
        </div>
    </c:if> 
                
    <tg:editProject experiment="${appVariables.experiment}" projid="${projid}" returnURL="show_project.jsp?projid=${projid}"/>  
 
    <p/>
  <display:table class="datatable" id="Rows" name="${pubs.rows}" defaultsort="1">
        <display:column title="Pub ID" sortable="true" headerClass="sortable">
            <a href="show_pub.jsp?pubid=${Rows.id}&projid=${projid}&swgid=${swgid}">${Rows.id}<a/>
        </display:column>
        <display:column title="Publication Title" sortable="true" headerClass="sortable">
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

