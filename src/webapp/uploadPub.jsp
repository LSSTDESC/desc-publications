<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib uri="http://displaytag.sf.net" prefix="display"%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script src="js/jquery-1.11.1.min.js"></script>
        <script src="js/jquery.validate.min.js"></script>
        <link rel="stylesheet" href="css/pubstyles.css">
        <title>Upload </title>
    </head>
    <body>
        <fmt:setTimeZone value="UTC"/>   

        <c:if test="${!empty msg}">
            <p id="pagelabel">${msg}</p> 
        </c:if>
            
        <c:choose>
            <c:when test="${empty param.paperid}">
                <sql:query var="list">
                    select db.paperid, pe.metavalue title from descpub_publication db join descpub_publication_metadata pe on db.paperid = pe.paperid
                    join descpub_metadata me on me.metaid = pe.metaid and me.metaid = 1
                    order by db.paperid
                </sql:query>

                <p id="pagelabel"> Choose your paper: </p>
                <form action="uploadPub.jsp">
                    <select name="paperid" size="8" required>
                        <c:forEach var="p" items="${list.rows}">
                            <option value="${p.paperid}">${p.title}</option>
                        </c:forEach>
                    </select>
                    <br>
                    <input type="submit" value="Go" name="submit">
                </form>            
            </c:when>
            <c:otherwise>   
                <h2>Paper <strong>DESC-${param.paperid}</strong></h2>
                <sql:query var="papertitle">
                    select db.paperid, pe.metavalue title from descpub_publication db join descpub_publication_metadata pe on db.paperid = pe.paperid
                    join descpub_metadata me on me.metaid = pe.metaid and me.metaid = 1 
                    where db.paperid = ?
                    <sql:param value="${param.paperid}"/>
                </sql:query>
                    
                <c:set var="papertitle" value="${papertitle.rows[0].title}"/>
                    
                <sql:query var="list">
                    select paperid, version, tstamp, to_char(tstamp,'Mon-dd-yyyy') pst, remarks from descpub_publication_versions where paperid=? order by version
                    <sql:param value="${param.paperid}"/>
                </sql:query>

                <display:table class="datatable" id="row" name="${list.rows}">
                    <display:column title="Title" group="1">
                        ${papertitle}
                    </display:column>
                    <display:column title="Links" sortable="true" headerClass="sortable">
                        <a href="download?paperid=${row.paperid}&version=${row.version}">Download version ${row.version}</a>
                    </display:column>
                    <display:column title="Remarks" property="remarks"/>
                    <display:column title="Uploaded (UTC)">
                       <fmt:formatDate value="${row.tstamp}" pattern="yyyy-MM-dd HH:mm:ss"/>
                    </display:column>
                    <display:column title="Uploaded (PDT/PST)">
                        ${row.pst}
                    </display:column>
                </display:table>
                <p/> 
                    <hr align="left" width="40%"/>   	
                <p id="pagelabel">Upload new version of DESC-${param.paperid}</p>
                
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
            </c:otherwise>
        </c:choose>
    </body>
</html>
