<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>  
    <head>
        <title>${appVariables.experiment} Group Manager: Permission Denied</title>
    </head>
    <body>
               
        <h1>Permission Denied</h1>
        <c:choose>
            <c:when test="${param.errmsg == '1'}">
                <h3>You do not have permission to perform this action. Please contact the Publications Board for help.</h3>
            </c:when>
        <c:when test="${param.errmsg == '2'}">
            <h3>Removing all working groups is not allowed. Projects must have at least one working group associated with it. </h3>
        </c:when>
        </c:choose>
    </body>
</html>
