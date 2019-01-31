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
                        
        <sql:query var="vers" >
            select distinct p.paperid, p.title, p.pubstatus, p.pubstate, p.pubtype, p.createdate, p.modifydate from descpub_publication p left join descpub_publication_versions v on v.paperid=p.paperid
            order by p.paperid desc
        </sql:query>

        <c:if test="${vers.rowCount>0}">  
            <h2>LSST DESC Documents</h2>
            <display:table class="datatable" id="record" name="${vers.rows}" cellpadding="5" cellspacing="5">
                <display:column title="DESC ID" style="text-align:left;" group="1" sortable="true" headerClass="sortable">
                    <a href="show_pub.jsp?paperid=${record.paperid}">DESC-${record.paperid}</a>
                </display:column>
                <display:column title="Title" property="title" style="text-align:left;" group="2" sortable="true" headerClass="sortable"/>
                <display:column title="Document status" property="pubstatus" style="text-align:left;" sortable="true" headerClass="sortable"></display:column> 
                <display:column title="Document state" property="pubstate" style="text-align:left;" sortable="true" headerClass="sortable"></display:column> 
                <display:column title="Doc type" property="pubtype" style="text-align:left;" sortable="true" headerClass="sortable"></display:column>
                <display:column title="Created" property="createdate" style="text-align:left;" sortable="true" headerClass="sortable"></display:column> 
                <display:column title="Modified" property="modifydate" style="text-align:left;" sortable="true" headerClass="sortable"></display:column> 
                <display:column title="# Versions" style="text-align:left;">
                    <sql:query var="v">
                        select max(version) version from descpub_publication_versions where paperid = ?
                        <sql:param value="${record.paperid}"/>
                    </sql:query>
                    ${v.rows[0].version}
                </display:column>
                        
                <display:column title="Lead Authors" sortable="true" headerClass="sortable" style="text-align:left;">
                     <sql:query var="auth">
                         select  m.firstname, m.lastname, m.memidnum from um_member m join profile_ug ug on m.memidnum = ug.memidnum and ug.experiment = ? 
                         where ug.group_id = ? 
                         <sql:param value="${appVariables.experiment}"/>
                         <sql:param value="paper_leads_${record.paperid}"/>
                     </sql:query>
                         <c:forEach var="au" items="${auth.rows}">         
                     <a href="https://srs.slac.stanford.edu/GroupManager/exp/LSST-DESC/protected/user.jsp?memidnum=${au.memidnum}&recType=INDB">${au.firstname} ${au.lastname}</a> &nbsp;
                         </c:forEach>
                </display:column>        
            </display:table>
        </c:if>
    </body>
</html>
