<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
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
        
        <fmt:setTimeZone value="UTC"/>  
        <c:if test="${!empty msg}">
            <p id="pagelabel">${msg}</p> 
        </c:if>
         
        <c:if test="${!gm:isUserInGroup(pageContext,'lsst-desc-members')}">  
            <c:redirect url="noPermission.jsp?errmsg=7"/>
        </c:if>
        
        <c:set var="paperid" value="${param.paperid}"/>
        <c:set var="swgid" value="${param.swgid}"/>
        <c:set var="mgrgrp" value="paper_${param.paperid}"/>
        <sql:query var="info">
            select project_id from descpub_publication where paperid = ?
            <sql:param value="${paperid}"/>
        </sql:query>
                
        <sql:query var="pubs">
          select paperid, state, title, journal, pubtype, summary, to_char(added,'yyyy-mon-dd') added, to_char(date_modified,'yyyy-mon-dd') moddate, builder_eligible, keypub,
          pb_reader_approved, arxiv, published_reference, project_id, short_title from descpub_publication where paperid = ?
            <sql:param value="${paperid}"/>
        </sql:query>
        
        <sql:query var="countpapers">
            select count(*) from descpub_publication where project_id = ?
            <sql:param value="${projid}"/>
        </sql:query>   
            
        <%-- get working groups associated with this pub --%>
        <sql:query var="swglist">
            select wg.id, wg.name from descpub_project_swgs jo join descpub_swg wg on jo.swg_id = wg.id where jo.project_id = ?
            <sql:param value="${info.rows[0].project_id}"/>
        </sql:query>
        
        <sql:query var="vers">
            select paperid, version, tstamp, to_char(tstamp,'Mon-dd-yyyy') pst, remarks from descpub_publication_versions where paperid=? order by version
            <sql:param value="${param.paperid}"/>
        </sql:query>
        <h2>Paper <strong>DESC-${param.paperid}</strong></h2>
  
        <display:table class="datatable" id="Row" name="${pubs.rows}">
            <display:column title="Project">
                <a href="show_project.jsp?projid=${Row.project_id}">${Row.project_id}</a>
            </display:column>
            <display:column title="Title" group="1">
                        ${Row.title}
            </display:column>
            <display:column title="Short title">
                        ${Row.short_title}
            </display:column>
            <display:column title="Status">
                        ${Row.state}
            </display:column>
            <display:column title="Journal">
                        ${Row.journal}
            </display:column>
            <display:column title="Doc Type">
                        ${Row.pubtype}
            </display:column>
            <display:column title="Summary" class="changeSummaryWidth">
                        ${Row.summary}
            </display:column>
            <display:column title="Created">
                        ${Row.added}
            </display:column>
            <display:column title="Last modified">
                        ${Row.moddate}
            </display:column>
            <display:column title="Builder Eligible">
                        ${Row.builder_eligible}
            </display:column>
            <display:column title="Key publication">
                        ${Row.keypub}
            </display:column>
            <display:column title="Passed internal review">
                        ${Row.pb_reader_approved}
            </display:column>
            <c:if test="${(gm:isUserInGroup(pageContext,'GroupManagerAdmin') || gm:isUserInGroup(pageContext,mgrgrp))}">
                <display:column title="Action">
                    <a href="editLink.jsp?&paperid=${Row.paperid}">Edit</a>
                </display:column>
            </c:if>
            <display:column title="Authorship">
                <a href="requestAuthorship.jsp?&paperid=${Row.paperid}">Request Authorship</a>
            </display:column>
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