<%-- 
    Document   : show_pub
    Created on : Jul 12, 2017, 6:49:15 PM
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
        <title>Publications</title>
    </head>
    <body>
        <h1>Publications</h1>
        <sql:query var="pubs" dataSource="jdbc/config-dev">
            select id,title from descpub_publication
        </sql:query>
        
       <display:table class="datatable" id="Rows" name="${pubs.rows}" defaultsort="1">
           <display:column title="Id" sortable="true"  headerClass="sortable">
               <a href="publication.jsp?id=${Rows.id}">${Rows.id}</a>
           </display:column>
           <display:column title="Name" sortable="true"  headerClass="sortable">
               ${Rows.title}
           </display:column>
       </display:table>
        
    </body>
</html>
