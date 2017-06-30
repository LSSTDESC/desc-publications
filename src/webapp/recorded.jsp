<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Vote Recorded</title>
    </head>
    <body>
        <h1>Thank you for voting</h1>
        <c:choose>
            <c:when test="${empty param.reason}">
                <p>Your vote has been recorded.</p>
            </c:when>
            <c:otherwise>
                <p>Your vote has NOT been recorded because ${param.reason}</p>
            </c:otherwise>
        </c:choose>
    </body>
</html>
