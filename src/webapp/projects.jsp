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
        <h1> <img name="construction" src="Images/construction.gif" border=0>   
        THE DESC PUBLICATION SYSTEM IS A WORK IN PROGRESS.  
        </h1>
        
        <sql:query var="projects" dataSource="jdbc/config-dev">
            select 
            p.id projid, p.keyprj, p.title, p.state, p.created, p.abstract abs, p.comments,
            wg.name swgname, wg.id swgid, wg.convener_group_name cgn,
            pro.id memid, pro.relation, pro.memidnum, pro.project_id, 
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
           <display:column title="Id" group="1">
               <a href="show_project.jsp?projid=${Rows.projid}&swgid=${Rows.swgid}">${Rows.projid}</a>
           </display:column>
           <display:column title="Title" group="1">
               <a href="show_project.jsp?projid=${Rows.projid}&swgid=${Rows.swgid}">${Rows.title}</a>
           </display:column>
           <display:column title="Working Group(s)" group="2">
               <a href="show_swg.jsp?swgid=${Rows.swgid}&swgname=${Rows.swgname}">${Rows.swgname}></a>
           </display:column>
           <display:column title="Members">
               <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/user.jsp?memidnum=${Rows.memid}">${Rows.first_name} ${Rows.last_name}</a>
           </display:column>
           <display:column title="State">
               ${Rows.state}
           </display:column>
           <display:column title="Documents">
               <sql:query var="pubcnt" dataSource="jdbc/config-dev">
                    select project_id, count(project_id) as tot from descpub_publication where project_id = ? group by project_id order by project_id
                    <sql:param value="${Rows.projid}"/>
                </sql:query>
                ${pubcnt.rows[0].tot}
           </display:column>
            <display:column title="Publications">
               <sql:query var="pubcnt" dataSource="jdbc/config-dev">
                    select project_id, count(project_id) as tot from descpub_publication where project_id = ? group by project_id order by project_id
                    <sql:param value="${Rows.projid}"/>
                </sql:query>
                ${pubcnt.rows[0].tot}
            </display:column>
       </display:table>
             
    </body>
</html>
