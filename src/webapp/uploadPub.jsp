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
            <c:when test="${empty param.paperId}">
                <sql:query var="list">
                    select paperid, title from descpub_publication
                </sql:query>

                <p id="pagelabel"> Choose your paper: </p>
                <form action="uploadPub.jsp">
                    <select name="paperId" size="8" required>
                        <c:forEach var="p" items="${list.rows}">
                            <option value="${p.paperid}">${p.title}</option>
                        </c:forEach>
                    </select>
                    <br>
                    <input type="submit" value="Go" name="submit">
                </form>
            </c:when>
            <c:otherwise>   

                <h2>Paper <strong>DESC-${param.paperId}</strong></h2>

                <sql:query var="list">
                    select paperid, version, tstamp, remarks from descpub_publication_versions where paperId=? order by version
                    <sql:param value="${param.paperId}"/>
                </sql:query>

                <display:table class="datatable" id="row" name="${list.rows}">
                    <display:column title="Version" sortable="true" headerClass="sortable" property="version"/>
                    <display:column title="Remarks" property="remarks"/>
                    <display:column title="Uploaded (UTC)">
                       <fmt:formatDate value="${row.tstamp}" pattern="yyyy-MM-dd HH:mm:ss"/>
                    </display:column>
                    <display:column title="Links">
                        <a href="download?paperId=${row.paperId}&version=${row.version}">Download</a>
                    </display:column>
                </display:table>
                <p/> <hr/>
                <p id="pagelabel">Upload new version</p>
                <%-- upload.jsp is defined in web.xml and maps to the servlet that does the uploading --%>
                <form action="upload.jsp" method="post" enctype="multipart/form-data">
                    <input type="file" name="fileToUpload" id="fileToUpload">
                    <p>
                        Remarks: <input type="text" name="remarks" required>
                    <p>
                        <input type="submit" value="Upload Document" name="submit">
                        <input type="hidden" name="forwardTo" value="/uploadPub.jsp?paperId=${param.paperId}" />
                        <input type="hidden" name="paperId" value="${param.paperId}"/>
                </form>  
            </c:otherwise>
        </c:choose>
    </body>
</html>
