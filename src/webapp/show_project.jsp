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
       <script src="js/jquery-1.11.1.min.js"></script>
       <script src="js/jquery.validate.min.js"></script>
   <%--    <script>
           function showchanges()
           {
               var f_swgid = $("#swgid").val();
               $("#label_swgid").html(f_swgid);
           }
       </script> --%>
      <title>LSST-DESC Projects</title>
</head>

<body>
  
    <c:set var="projid" value="${param.projid}"/>
    <c:set var="swgid" value="${param.swgid}"/>
    
    <%--
    <sql:query var="projects" dataSource="jdbc/config-dev">
        select p.id, p.keyprj, p.title, p.state, p.created, wg.name swgname, wg.id swgid, wg.convener_group_name cgn, p.abstract abs, p.comments 
        from descpub_project p left join descpub_project_swgs ps on p.id=ps.project_id
        left join descpub_swg wg on ps.swg_id=wg.id where p.id = ?
        <sql:param value="${projid}"/>
    </sql:query>  
    
    <sql:query var="pubs" dataSource="jdbc/config-dev">
        select * from descpub_publication where project_id = ?
        <sql:param value="${projid}"/>
    </sql:query> --%>
        
   <tg:editProject experiment="${appVariables.experiment}" projid="${projid}" swgid="${swgid}"/>  
 
 <%--
  <display:table class="datatable" id="Rows" name="${projects.rows}" defaultsort="1">
  </display:table> --%>

 <%--
 test jquery<br/>
       
 <div>
   what is your swg id ?<br/>
   <input type="text" name="swgid" id="swgid"/> <br/>
   your swgid: <label id="label_swgid"></label><br/>
   <input type="button" value="submit data" onclick="showchanges();"/>
 </div>
 --%>
</body>
</html>
    
    
</html>

