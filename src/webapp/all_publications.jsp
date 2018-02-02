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
                        
            <%--
            select p.title, p.paperid, p.state, p.status, to_char(v.tstamp,'yyyy-Mon-dd'), version, location from descpub_publication p left join descpub_publication_versions v on v.paperid=p.paperid
            order by v.paperid
            --%>
        <sql:query var="vers" >
            select distinct p.paperid, p.title, p.state, p.status, p.pubtype from descpub_publication p left join descpub_publication_versions v on v.paperid=p.paperid
            order by p.paperid desc
        </sql:query>
            
        <c:if test="${vers.rowCount>0}">    
            <display:table class="datatable" id="record" name="${vers.rows}">
                <display:column title="DESC ID" group="1">
                    <a href="show_pub.jsp?paperid=${record.paperid}">DESC-${record.paperid}</a>
                </display:column>
                <display:column title="Title" property="title" style="text-align:left;" group="2"/>
                <display:column title="State" property="state" group="3"></display:column> 
                <display:column title="Status" property="status"></display:column> 
                <display:column title="Doc type" property="pubtype"></display:column> 
                <display:column title="Versions" style="text-align:left;">
                    <sql:query var="v">
                        select max(version) version from descpub_publication_versions where paperid = ?
                        <sql:param value="${record.paperid}"/>
                    </sql:query>
                        ${v.rows[0].version}
                </display:column>
            </display:table>
        </c:if>
    </body>
</html>
