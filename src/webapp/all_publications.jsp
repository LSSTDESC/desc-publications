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
          <link rel="stylesheet" type="text/css" href="css/pubstyles.css">
      <title>DESC Documents</title>
    </head>
    <body>
        <tg:underConstruction/>
        
        <sql:query var="pubs" >
            select paperid, added, state, keypub, title, project_id, pubtype from descpub_publication order by paperid
        </sql:query>
          
        <display:table class="datatable" id="Row" name="${pubs.rows}">
            <display:column title="Paper ID">
                <a href="show_pub.jsp?paperid=${Row.paperid}&projid=${Row.project_id}&swgid=${Row.swgid}">${Row.paperid}</a>
            </display:column>
            <display:column title="Title">
                <a href="show_pub.jsp?paperid=${Row.paperid}&projid=${Row.project_id}&swgid=${Row.swgid}">${Row.title}</a>
            </display:column>
            <display:column title="Key Publication">
                ${Row.keypub}
            </display:column>  
            <display:column title="State">
                ${Row.state}
            </display:column>  
            <display:column title="Created">
                ${Row.added}
            </display:column>  
            <display:column title="Working Group(s)">
               <sql:query var="wgs">
                        select s.id, s.name from descpub_swg s join descpub_project_swgs j on s.id = j.swg_id and j.project_id = ?
                        <sql:param value="${Row.project_id}"/>
                </sql:query>
                <c:if test="${wgs.rowCount>0}">
                    <c:forEach var="wg" items="${wgs.rows}">
                         <a href="show_swg.jsp?swgid=${wg.id}&swgname=${wg.name}">${wg.name}</a><br/>
                    </c:forEach>
                </c:if>
            </display:column>
                         
            <display:column title="Lead Authors">
                <sql:query var="leads">
                    select distinct ug.memidnum, vi.first_name, vi.last_name, vi.email from profile_ug ug join profile_user vi on vi.memidnum = ug.memidnum 
                    where ug.experiment = ? and ug.group_id = ?
                    <sql:param value="${appVariables.experiment}"/>
                    <sql:param value="paper_${Row.paperid}"/>
                </sql:query>
                <c:if test="${leads.rowCount > 0}">
                    <c:forEach var="a" items="${leads.rows}">
                        <a href="http://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/user.jsp?memidnum=${a.memidnum}&recType=INDB&verification=A">${a.first_name} ${a.last_name}</a><br/>
                    </c:forEach>        
                </c:if>    
            </display:column>
        </display:table>
            
    </body>
</html>
