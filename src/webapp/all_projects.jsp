<%-- 
    Document   : all_projects
    Created on : Aug 23, 2017, 11:58:57 AM
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
      <title>DESC All Projects</title>
    </head>
    <body>
        <tg:underConstruction/>
         
        
        <sql:query var="pjs" >
             select id, title, created, lastmodified from descpub_project where projectstatus != 'Inactive' order by id
        </sql:query>   
         
        <h2>LSST DESC Projects</h2>
             
        <display:table class="datatable" id="Row" name="${pjs.rows}" cellspacing="10" cellpadding="10">
             <display:column title="Working Groups" style="text-align:left;" sortable="true" headerClass="sortable">
                <sql:query var="wgs">
                        select s.id, s.name from descpub_swg s join descpub_project_swgs j on s.id = j.swg_id and j.project_id = ?
                        <sql:param value="${Row.id}"/>
                </sql:query>
                <c:if test="${wgs.rowCount>0}">
                    <c:forEach var="w" items="${wgs.rows}">  
                          <a href="show_swg.jsp?swgid=${w.id}">${w.name}</a><br/>
                    </c:forEach>  
                </c:if>
            </display:column>  
            <display:column title="Project ID" property="id" style="text-align:left;" sortable="true" headerClass="sortable"/>
            <display:column title="Project Title" style="text-align:left;" sortable="true" headerClass="sortable">
                <a href="show_project.jsp?projid=${Row.id}">${Row.title}</a>
            </display:column>
            <c:if test="${! empty Row.active}">
                <display:column title="Active" property="active" style="text-align:left;"/>
            </c:if>
            <display:column title="Created" property="created" style="text-align:left;" sortable="true" headerClass="sortable"/>
            <display:column title="Last Modified" property="lastmodified" style="text-align:left;" sortable="true" headerClass="sortable"/>
        </display:table>
        
       <a href="projectSubscription.jsp">Subscription to projects</a>
        
    </body>
    
</html>
