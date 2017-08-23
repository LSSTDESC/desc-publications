<%-- 
    Document   : all_publications
    Created on : Aug 22, 2017, 5:12:47 PM
    Author     : chee
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="f" uri="http://lsstdesc.org/functions" %>
<%@taglib tagdir="/WEB-INF/tags/" prefix="tg"%>
<!DOCTYPE html>

<html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <%--  <link rel="stylesheet" href="css/site-demos.css"> --%>
      <title>DESC Publications</title>
    </head>
    <body>
        <tg:underConstruction/>
        
        <sql:query var="pubs" dataSource="jdbc/config-dev">
            select 
            p.ID pubid,
            p.TITLE, 
            p.PROJECT_ID,
            p.PUBTYPE,
            wg.swg_id
            from 
            descpub_publication p join descpub_project pro on p.project_id = pro.id
            join descpub_project_swgs wg on wg.project_id = p.project_id
        </sql:query>
            
        <display:table class="datatable"  id="Row" name="${pubs.rows}">
            <display:column title="Publication Title">
                <a href="show_pub.jsp?pubid=${Row.pubid}&projid=${Row.project_id}&swgid=${Row.swg_id}">${Row.title}</a>
            </display:column>
        </display:table>
         
