<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib uri="http://srs.slac.stanford.edu/displaytag" prefix="displayutils" %>
<%@taglib prefix="gm" uri="http://srs.slac.stanford.edu/GroupManager"%>
<%@taglib tagdir="/WEB-INF/tags" prefix="tg"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="css/pubstyles.css">
    </head>
    <body>
        
        <tg:underConstruction/>
        
        <fmt:setTimeZone value="UTC"/>  
        <c:if test="${!empty msg}">
            <p id="pagelabel">${msg}</p> 
        </c:if>
         
        <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
            <c:redirect url="noPermission.jsp?errmsg=7"/>
        </c:if>
        
        <c:set var="paperid" value="${param.paperid}"/>
        <c:set var="mgrgrp" value="paper_${param.paperid}"/>
        
        <%--
        <sql:query var="info">
            select project_id, pubtype from descpub_publication where paperid = ?
            <sql:param value="${paperid}"/>
        </sql:query>
        <c:set var="pubtype" value="${info.rows[0].pubtype}"/>
             --%>
             
        <sql:query var="pubs">
            select * from descpub_publication where paperid = ?
            <sql:param value="${paperid}"/>
        </sql:query>   
            
        <c:set var="pubtype" value="${pubs.rows[0].pubtype}"/>
        <c:set var="projid" value="${pubs.rows[0].project_id}"/>

        <sql:query var="fi">
            select pb.metaid, me.data, me.label, me.datatype, pb.multiplevalues, pb.formposition from descpub_pubtype_fields pb join descpub_metadata me on pb.metaid = me.metaid
            where pb.pubtype = ? order by pb.formposition
            <sql:param value="${pubtype}"/>
        </sql:query>
               
        <p id="pagelabel">${pubs.rows[0].title}</p>
          
        <sql:query var="countpapers">
            select count(*) from descpub_publication where project_id = ?
            <sql:param value="${projid}"/>
        </sql:query>   
           
        <sql:query var="vers">
            select paperid, version, tstamp, to_char(tstamp,'Mon-dd-yyyy') pst, remarks from descpub_publication_versions where paperid=? order by version desc
            <sql:param value="${param.paperid}"/>
        </sql:query>
            
        <h2>Paper <strong>DESC-${param.paperid}</strong></h2> 
        <display:table class="datatable" id="fie" name="${pubs.rows}">
             <c:forEach var="x" items="${fi.rows}">
                 <display:column title="${x.label}"  property="${x.data}" />
            </c:forEach>
        </display:table>
        <p/>  
        
        <c:if test="${vers.rowCount > 0}">
            <display:table class="datatable" id="row" name="${vers.rows}">
                <display:column title="Links" sortable="true" headerClass="sortable">
                    <a href="download?paperid=${row.paperid}&version=${row.version}">Download version ${row.version}</a>
                </display:column>
                <display:column title="Remarks" property="remarks"/>
                <display:column title="Uploaded (UTC)">
                   <fmt:formatDate value="${row.tstamp}" pattern="yyyy-MM-dd HH:mm:ss"/>
                </display:column>
            </display:table>
            <p/> 
        </c:if>
        
 
<form action="upload.jsp" method="post" enctype="multipart/form-data">
    <div>
        <fieldset class="fieldset-auto-width">
  <legend><strong>Upload</strong></legend><p/>
  Upload new version of DESC-${param.paperid}<p/>
  <input type="file" name="fileToUpload" id="fileToUpload"><p/>
  Remarks: <input type="text" name="remarks" required><p/>
  <input type="submit" value="Upload Document" name="submit">
  <input type="hidden" name="forwardTo" value="/uploadPub.jsp?paperid=${param.paperid}" />
  <input type="hidden" name="paperid" value="${param.paperid}"/>
 </fieldset>
    </div>
</form>
            
            
    </body>
</html>