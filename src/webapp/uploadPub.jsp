<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
              
        <c:choose>
            <c:when test="${!empty msg}">
                <p id="pagelabel">${msg}</p> 
                <a href="all_publications.jsp">return to publication page</a>
            </c:when>
            <c:when test="${empty param}">
                <sql:query var="list">
                    select paperid, title, project_id, swgid from descpub_publication
                </sql:query>
                
                Choose your paper:<p/>
                <form action="uploadPub.jsp">
                     <select name="paper" size="8" required>
                        <c:forEach var="p" items="${list.rows}">
                            <option value="${p.paperid}:${p.project_id}:${p.swgid}:${p.title}">${p.title}</option>
                        </c:forEach>
                     </select>
                     <p/>
                     Remarks: <br/>
                     <input type="text" id="remarks" name="remarks"/>
                     <p/>
                     <input type="submit" value="Go" name="submit">
                </form>
            </c:when>
            <c:when test="${!empty param}">   
                <c:if test="${!empty param.paper}">
                  <c:set var="array" value="${fn:split(param.paper,':')}"/> 
                  <c:set var="paperid" value="${array[0]}"/>
                  <c:set var="projid" value="${array[1]}"/>
                  <c:set var="wgid" value="${array[2]}"/>
                  <c:set var="title" value="${array[3]}"/> 
                  <c:set var="remarks" value="${param.remarks}"/>
                </c:if> 
                      
                You are about to upload a new version of <strong>${title}</strong><p/>
                
                 
                <form action="upload" method="post" enctype="multipart/form-data">
                    <input type="file" name="fileToUpload" id="fileToUpload">
                    <input type="submit" value="Upload Document" name="submit">
                    <input type="hidden" name="forwardTo" value="/uploadPub.jsp" />
                    <input type="hidden" name="paperid" value="${paperid}"/>
                    <input type="hidden" name="projid" value="${projid}"/>
                    <input type="hidden" name="wgid" value="${wgid}"/>
                    <input type="hidden" name="title" value="${title}"/>
                    <input type="hidden" name="remarks" value="${remarks}"/>
                </form>  
                
                
            </c:when>
        </c:choose>
    </body>
</html>
