<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="f" uri="http://lsstdesc.org/functions" %>
<!DOCTYPE html>

<html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <%--  <link rel="stylesheet" href="css/site-demos.css"> --%>
      <title>DESC Projects</title>
    </head>
    <body>
        
        <sql:query var="projects" dataSource="jdbc/config-dev">
            select 
            p.id, p.keyprj, p.title, p.state, p.created, p.abstract abs, p.comments, count(pub.id) as pubtot,
            wg.name swgname, wg.id swgid, wg.convener_group_name cgn,
            pro.id, pro.relation, pro.memidnum, pro.project_id, 
            up.first_name, up.last_name
            from descpub_project p left join descpub_project_swgs ps on p.id=ps.project_id
            left join descpub_swg wg on ps.swg_id=wg.id 
            left join  descpub_projectmember pro on pro.project_id = p.id 
            left join descpub_publication pub on pub.project_id = p.id
            left join profile_user up on up.memidnum = pro.memidnum and up.experiment = ?
            group by p.id, p.keyprj, p.title, p.state, p.created, p.abstract, p.comments, pub.id, wg.name, wg.id, wg.convener_group_name, 
            pro.id, pro.relation, pro.memidnum, pro.project_id, up.first_name, up.last_name
            order by p.id
            <sql:param value="${appVariables.experiment}"/>
        </sql:query>
         
       <h3>Projects</h3>
        
       <display:table class="datatable" name="${projects.rows}" id="Rows">
           <display:column title="Title" group="1">
               ${Rows.title}
           </display:column>
           <display:column title="Members">
               ${Rows.first_name} ${Rows.last_name}
           </display:column>
           <display:column title="State">
               ${Rows.state}
           </display:column>
           <display:column title="Working Group(s)">
               ${Rows.swgname}
           </display:column>
           <display:column title="Documents">
               ?
           </display:column>
            <display:column title="Publications">
              ${Rows.pubtot}
            </display:column>
       </display:table>
             
    </body>
</html>
