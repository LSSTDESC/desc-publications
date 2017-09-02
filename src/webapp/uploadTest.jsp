<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Upload test</title>
    </head>
    <body>
        <h1>Upload test!</h1>
        <c:if test="${!empty msg}">
            <p>${msg}</p>
        </c:if>
        <form action="upload" method="post" enctype="multipart/form-data">
            <input type="file" name="fileToUpload" id="fileToUpload">
            <input type="submit" value="Upload Document" name="submit">
            <input type="hidden" name="forwardTo" value="/uploadTest.jsp" />
        </form>
    </body>
</html>
